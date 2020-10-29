unit uWorkers;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit,
  superobject;

type
  TfWorkers = class(TForm)
    Layout1: TLayout;
    Edit1: TEdit;
    lHeader: TLabel;
    AddPersone: TCircle;
    Image4: TImage;
    lNoTasks: TLabel;
    Button1: TButton;
    Button2: TButton;
    layFlow: TFlowLayout;
    cbShowDeleted: TCheckBox;
    Label1: TLabel;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure cbShowDeletedChange(Sender: TObject);
    procedure AddPersoneMouseEnter(Sender: TObject);
    procedure AddPersoneMouseLeave(Sender: TObject);
    procedure AddPersoneClick(Sender: TObject);
  private
    { Private declarations }
    data: ISuperobject;
    selPersone : TControl;
    selID: integer;

    procedure onMouseEnter(sender: TObject);
    procedure onMouseLeave(sender: TObject);
    procedure onClick(sender: TObject);

    procedure onDelete(sender: TObject);
    procedure onRestore(sender: TObject);
  public
    { Public declarations }
    procedure Activate;
    procedure Update;
  end;

var
  fWorkers: TfWorkers;

implementation

{$R *.fmx}

uses uInterface, uAtlas, uConst, uData;

{ TfWorkers }

procedure TfWorkers.Activate;
begin
    data := AppInterface.onGetWorkersData;
    Update;
end;

procedure TfWorkers.AddPersoneClick(Sender: TObject);
var
    pers: ISuperObject;
    present: boolean;
begin
    if Trim( Edit1.Text ) = '' then
    begin
        AppInterface.MessageShow('Укажите имя сотрудника!');
        exit;
    end;


    present := false;

    /// проверка на наличие
    for pers in data do
    if AnsiUpperCase(pers.S['name']) = AnsiUpperCase(Edit1.Text) then
    begin
        /// есть такой
        present := true;

        // если он в удаленных, то пользователь мог его не увидеть, если не
        // установлена галочка показа удаленных.
        // просто достаем его из удаленных
        if pers.B['isDel'] then pers.B['isDel'] := false;

        Edit1.Text := '';

        Update;

        break;
    end;

    /// уже есть - ничего делать не будем
    if present then exit;

    /// добавляем нового сотрудника
    pers := SO(WORKER_SHABLON);
    pers.S['name'] := Edit1.Text;
    pers.I['id'] := AppData.GetNewWorkerID;
    data.AsArray.Add( pers );

    /// обновляем интерфейс
    Edit1.Text := '';

    Update;
end;

procedure TfWorkers.AddPersoneMouseEnter(Sender: TObject);
begin
    AppInterface.ShowHint('Добавление нового участника бригады');
end;

procedure TfWorkers.AddPersoneMouseLeave(Sender: TObject);
begin
    AppInterface.ShowHint('');
end;

procedure TfWorkers.Button1Click(Sender: TObject);
begin
    AppInterface.onWorkerSave(data);
end;

procedure TfWorkers.Button2Click(Sender: TObject);
begin
    AppInterface.onWorkerCancel;
end;

procedure TfWorkers.cbShowDeletedChange(Sender: TObject);
begin
    Update;
end;

procedure TfWorkers.onClick(sender: TObject);
begin
    selPersone := sender as TLayout;
    selID := selPersone.Tag;
    Update;
end;

procedure TfWorkers.onDelete(sender: TObject);
var
    pers : ISuperObject;
    id : integer;
begin
    id := (sender as TControl).Tag;

    for pers in data do
    if pers.I['id'] = id then pers.B['isDel'] := true;

    Update;
end;

procedure TfWorkers.onMouseEnter(sender: TObject);
begin
     if (Sender as TControl).Name = 'Delete' then AppInterface.ShowHint('Удалить участника бригады');
     if (Sender as TControl).Name = 'Restore' then AppInterface.ShowHint('Восстановить удаленного участника бригады');
end;

procedure TfWorkers.onMouseLeave(sender: TObject);
begin
     AppInterface.ShowHint('');
end;

procedure TfWorkers.onRestore(sender: TObject);
var
    pers : ISuperObject;
    id : integer;
begin
    id := (sender as TControl).Tag;

    for pers in data do
    if pers.I['id'] = id then pers.B['isDel'] := false;

    Update;
end;

procedure TfWorkers.Update;
var
    i: integer;
    lay: TLayout;
    img: TImage;
    lab: TLabel;
    pers: ISuperObject;
begin
    if Not Assigned(data) then exit;

    /// чистим список бригады
    for I := layFlow.ControlsCount-1 downto 0 do
    layFlow.Controls[i].Free;

    /// заполняем список
    for pers in data do                                        /// перебираем участников бригады

    if not Assigned(pers.O['isDel']) or                        /// если еще не существует признака удаления
       (Assigned(pers.O['isDel']) and not pers.B['isDel']) or  /// или существует но не установлен
       (Assigned(pers.O['isDel']) and pers.B['isDel'] and cbShowDeleted.IsChecked )
                                                               /// или установлен, но удаленные нужно показать
    then

    begin                                                  /// будем отображать в интерфейсе
        /// клонируем болванку элемента списка
        lay := fAtlas.layWorker.Clone(layFlow) as TLayout;
        lay.Parent := layFlow;
        lay.Tag := pers.I['id'];
        lay.OnClick := onClick;

        /// перебираем
        if Assigned(lay) then
        for i := 0 to lay.ComponentCount-1 do
        begin

            if lay.Components[i].Tag = WORKER_KIND then
            begin
                if Assigned(pers.O['isBrigadir']) and pers.B['isBrigadir']
                then (lay.Components[i] as TImage).Bitmap.Assign( fAtlas.iBrigadir.MultiResBitmap[0].Bitmap )
                else (lay.Components[i] as TImage).Bitmap.Assign( fAtlas.iWorker.MultiResBitmap[0].Bitmap );
            end;

            if lay.Components[i].Tag = WORKER_NAME then
            begin
                (lay.Components[i] as TLabel).Text := pers.S['name'];
                if pers.B['isDel']
                then (lay.Components[i] as TLabel).TextSettings.FontColor := TAlphaColorRec.Darkgrey
                else (lay.Components[i] as TLabel).TextSettings.FontColor := TAlphaColorRec.Black;
            end;

            if lay.Components[i].Tag = WORKER_ISDEL then (lay.Components[i] as TControl).Visible := pers.B['isDel'];

            if lay.Components[i].Tag = WORKER_DELETE then
            begin
                (lay.Components[i] as TControl).Visible := (selID = pers.I['id']) and not pers.B['isDel'];
                (lay.Components[i] as TControl).Tag := pers.I['id'];
                (lay.Components[i] as TControl).name := 'Delete';
                (lay.Components[i] as TControl).OnClick := onDelete;
                (lay.Components[i] as TControl).OnMouseEnter := onMouseEnter;
                (lay.Components[i] as TControl).OnMouseLeave := onMouseLeave;
            end;

            if lay.Components[i].Tag = WORKER_RESTORE then
            begin
                (lay.Components[i] as TControl).Visible := (selID = pers.I['id']) and pers.B['isDel'];
                (lay.Components[i] as TControl).Tag := pers.I['id'];
                (lay.Components[i] as TControl).name := 'Restore';
                (lay.Components[i] as TControl).OnClick := onRestore;
                (lay.Components[i] as TControl).OnMouseEnter := onMouseEnter;
                (lay.Components[i] as TControl).OnMouseLeave := onMouseLeave;
            end;

            if lay.Components[i].Tag = WORKER_BG then
            if selID = pers.I['id']
            then (lay.Components[i] as TRectangle).Fill.Kind := TBrushKind.Solid
            else (lay.Components[i] as TRectangle).Fill.Kind := TBrushKind.None;

        end;
    end;
end;

end.
