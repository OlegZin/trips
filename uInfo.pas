unit uInfo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts,
  superobject, FMX.Objects, Generics.Collections;

type
  TfInfo = class(TForm)
    Layout1: TLayout;
    lHeader: TLabel;
    lNoTasks: TLabel;
    layHeader: TLayout;
    sbList: TVertScrollBox;
  private
    { Private declarations }
    TaskLink : TDictionary<TComponent,ISuperObject>;

    data: ISuperObject;
    fTaskID : integer;
    fWorkerID : integer;

    selWorker: TLabel;

    procedure OnWorkerClick(sender: TObject);

  public
    { Public declarations }
    procedure onSpravAnswer(spravname: string; data: ISuperObject);
    procedure onTaskAddPersone(sender: Tobject);
    procedure onTaskRemovePersone(sender: Tobject);
    procedure onMouseEnter(sender: Tobject);
    procedure onMouseLeave(sender: Tobject);
    procedure Activate;
    procedure Update;
  end;
var
  fInfo: TfInfo;

implementation

{$R *.fmx}

uses uInterface, uAtlas, uData, uConst;

{ TfInfo }

procedure TfInfo.Activate;
/// автоматически вызываемый из fInterface метод, при переключении в данный режим
begin
    data := AppInterface.onGetInfoData;
    if not Assigned(data) then exit;
    Update;
end;

procedure TfInfo.onTaskAddPersone(sender: Tobject);
/// показываем справочник для выбора фамилии из бригады
///    по идее, в справочнике, открываемом на указанный день должны быть фамилиитолько
///    тех, струдников, которые "действительны" по стокам на этот день
begin
    fTaskID := (sender as TControl).Tag;
    AppInterface.onSpravRequest(onSpravAnswer, SPRAV_WORKERS);
end;

procedure TfInfo.onTaskRemovePersone(sender: Tobject);
begin
    if (fTaskId = 0) or (fWorkerId = 0) then exit;

    if AppInterface.onTaskRemovePersone( fTaskId, fWorkerId) then fWorkerID := 0;
end;

procedure TfInfo.OnWorkerClick(sender: TObject);
begin
    fTaskID := TaskLink[sender as TComponent].I['taskid'];
    fWorkerID := TaskLink[sender as TComponent].I['workerid'];

    if Assigned(selWorker) then selWorker.TextSettings.Font.Style := [];

    selWorker := sender as TLabel;
    selWorker.TextSettings.Font.Style := [TFontStyle.fsBold];
end;

procedure TfInfo.onMouseEnter(sender: Tobject);
begin
    if (sender as TControl).Name = 'bDayLess' then AppInterface.ShowHint('Сократить длительность задачи');
    if (sender as TControl).Name = 'bDayMore' then AppInterface.ShowHint('Продлить задачу');
    if (sender as TControl).Name = 'bTaskEdit' then AppInterface.ShowHint('Редактировать задачу');
    if (sender as TControl).Name = 'bTaskDelete' then AppInterface.ShowHint('Удалить задачу');
    if (sender as TControl).Name = 'bAddPersone' then AppInterface.ShowHint('Назначить исполнителя');
    if (sender as TControl).Name = 'bRemovePersone' then AppInterface.ShowHint('Убрать выбранного исполнителя');
    if (sender as TControl).Name = 'bCopyNext' then AppInterface.ShowHint('Скопировать состав исполнителей на следующий день');
end;

procedure TfInfo.onMouseLeave(sender: Tobject);
begin
    AppInterface.ShowHint('');
end;

procedure TfInfo.onSpravAnswer(spravname: string; data: ISuperObject);
/// получаем результат справочника и добавляем работника для указанной задачи, для текущего выбранного дня
begin
    if AppData.AddWorker(fTaskID, data) then AppInterface.Update;
end;

procedure TfInfo.Update;
var
    i : integer;
    task: ISuperObject;
    item: TControl;
    pers: integer;
    lab: TLabel;
begin
    if not Assigned(TaskLink)
    then TaskLink := TDictionary<TComponent,ISuperObject>.Create;

    TaskLink.Clear;

    lHeader.Text := data.S['month'] + ', ' + data.S['day'];

    if Assigned(data.O['tasks'])
    then layHeader.Height := lHeader.Height + 10
    else layHeader.Height := lHeader.Height + 120;

    /// чистим список задач
    for i := sbList.ComponentCount-1 downto 0 do
    /// вуажная проверка, поскольку к компонентам относится и скроллируемая область. ее нельзя херить...
        if sbList.Components[i] is TLayout
        then (sbList.Components[i] as TControl).Free;


    if Assigned(data.O['tasks']) then
    for task in data.O['tasks'] do
    begin
        /// копируем заготовку задачи
        item := fAtlas.layExample.Clone(sbList) as TControl;
        item.Parent := sbList;

        /// забиваем данными и вешаем обработчики на кнопки
        for I := 0 to item.ComponentCount-1 do
        begin
            /// оформление
            if item.Components[i].Tag = WORK_TYPE
            then (item.Components[i] as Tlabel).Text := task.S['WorkType'];

            if item.Components[i].Tag = WORK_ICON
            then (item.Components[i] as Timage).Bitmap.Assign( AppData.GetKindIcon( task.I['WorkTypeID'] ) );

            if item.Components[i].Tag = WORK_COLOR
            then (item.Components[i] as TRectangle).Fill.Color := AppData.GetKindColor( task.I['WorkTypeID'] );

            if item.Components[i].Tag = WORK_COLOR_GRADIENT
            then (item.Components[i] as TRectangle).Fill.Gradient.Color := AppData.GetKindColor( task.I['WorkTypeID'] );

            if item.Components[i].Tag = WORK_COLOR_CONTOUR
            then (item.Components[i] as TRectangle).Stroke.Color := AppData.GetKindColor( task.I['WorkTypeID'] );

            /// обработчики кнопок
            if item.Components[i].Tag = BUTTON_DAY_LESS then
            begin
                item.Components[i].Tag := task.I['id'];
                item.Components[i].Name := 'bDayLess';  /// имя для показа хинта при наведении мышки
                (item.Components[i] as TControl).OnMouseEnter := onMouseEnter;
                (item.Components[i] as TControl).OnMouseLeave := onMouseLeave;
                (item.Components[i] as TControl).OnClick := AppInterface.onTaskDayLess;
            end;

            if item.Components[i].Tag = BUTTON_DAY_MORE then
            begin
                item.Components[i].Tag := task.I['id'];
                item.Components[i].Name := 'bDayMore';
                (item.Components[i] as TControl).OnMouseEnter := onMouseEnter;
                (item.Components[i] as TControl).OnMouseLeave := onMouseLeave;
                (item.Components[i] as TControl).OnClick := AppInterface.onTaskDayMore;
            end;

            if item.Components[i].Tag = BUTTON_EDIT then
            begin
                item.Components[i].Tag := task.I['id'];
                item.Components[i].Name := 'bTaskEdit';
                (item.Components[i] as TControl).OnMouseEnter := onMouseEnter;
                (item.Components[i] as TControl).OnMouseLeave := onMouseLeave;
                (item.Components[i] as TControl).OnClick := AppInterface.onTaskEdit;
            end;

            if item.Components[i].Tag = BUTTON_DELETE then
            begin
                item.Components[i].Tag := task.I['id'];
                item.Components[i].Name := 'bTaskDelete';
                (item.Components[i] as TControl).OnMouseEnter := onMouseEnter;
                (item.Components[i] as TControl).OnMouseLeave := onMouseLeave;
                (item.Components[i] as TControl).OnClick := AppInterface.onTaskDelete;
            end;

            if item.Components[i].Tag = BUTTON_ADD_PERSONE then
            begin
                item.Components[i].Tag := task.I['id'];
                item.Components[i].Name := 'bAddPersone';
                (item.Components[i] as TControl).OnMouseEnter := onMouseEnter;
                (item.Components[i] as TControl).OnMouseLeave := onMouseLeave;
                (item.Components[i] as TControl).OnClick := onTaskAddPersone;
            end;

            if item.Components[i].Tag = BUTTON_REMOVE_PERSONE then
            begin
                item.Components[i].Tag := task.I['id'];
                item.Components[i].Name := 'bRemovePersone';
                (item.Components[i] as TControl).OnMouseEnter := onMouseEnter;
                (item.Components[i] as TControl).OnMouseLeave := onMouseLeave;
                (item.Components[i] as TControl).OnClick := onTaskRemovePersone;
            end;

            if item.Components[i].Tag = BUTTON_COPY_NEXT then
            begin
                item.Components[i].Tag := task.I['id'];
                item.Components[i].Name := 'bCopyNext';
                (item.Components[i] as TControl).OnMouseEnter := onMouseEnter;
                (item.Components[i] as TControl).OnMouseLeave := onMouseLeave;
                (item.Components[i] as TControl).OnClick := AppInterface.onTaskCopyNext;
            end;

            if item.Components[i].Tag = BUTTON_COPY_FULL then
            begin
                item.Components[i].Tag := task.I['id'];
                (item.Components[i] as TControl).OnClick := AppInterface.onTaskCopyFull;
            end;

            /// список сотрудников
            if (item.Components[i].Tag = BRIGADA) AND (item.Components[i] IS TFlowLayout) then
            for pers := 0 to task.A['brigada'].Length-1 do
            begin
                lab := TLabel.Create(item.Components[i]);
                lab.Parent := item.Components[i] as TControl;
                lab.HitTest := true;
                lab.AutoSize := true;
                lab.Margins.Left := 5;
                lab.Margins.Right := 5;
                lab.Cursor := crHandPoint;
                lab.StyledSettings := [TStyledSetting.Family, TStyledSetting.Size, TStyledSetting.FontColor];
                lab.Text := task.S['brigada['+IntToStr(pers)+'].name'];
                lab.TextSettings.WordWrap := false;

                /// привязываем id задачи и id работника
                TaskLink.Add(lab, SO('{taskid:'+task.S['id']+', workerid:'+ task.S['brigada['+IntToStr(pers)+'].id'] +'}') );
                if (fWorkerID = task.I['brigada['+IntToStr(pers)+'].id']) and
                   (fTaskID = task.I['id'])
                then
                begin
                    lab.TextSettings.Font.Style := [TFontStyle.fsBold];
                    selWorker := lab;
                end;

                lab.OnClick := onWorkerClick;
            end;

        end;

    end;

end;

end.

