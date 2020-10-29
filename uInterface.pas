unit uInterface;

interface

uses
    FMX.Controls, Generics.Collections, FMX.StdCtrls, SysUtils, FMX.Objects, UITypes, FMX.Types,
    FMX.Ani, FMX.Graphics, Math,
    uData, superobject, uConst, uAtlas, uMessage, uInfo, uQuestion;

type

    TInterface = class
      private
        Controls: TDictionary<string, TControl>;
            /// ������� ���������� � �������� ����� �����������������
            /// ����� �� �������� MODE_��� - �����

        ActivateEvents: TDictionary<TControl, TEvent>;
            /// ������ ������� ��������� ������ �������(��������)
            /// TControl - ������ �� TDictionary Controls

{
        SelIndex: integer;  /// ������ ���������� ���.
            ///    �������� � ���, ��� ������ ������ ��� ������ �� ������� ��������� ���� "������".
            ///    �.�. ��� ������ ��������� ����� ������� ������, ������� �������������� ������ �� �������
            ///    �������� �������
}        LastMode: string;
         fTaskID: integer;
            /// ��������� �������� id ������, �� ������� ��������� ���� �������

        Mode: string;
            /// ������� ����� ����������� ������ (�������������� � �������). ��������:
            /// 'modeNone' = ����������� �����������
            /// 'modeInfo' = ����������� ���������� ���������� ���
            /// 'modeTask' = ���� ��������/�������������� ������
            /// �������� �������� ������ � ������� Controls

        SpravCallback: TSpravAnsverEvent;
            /// ����� �������� ������ � �����
            /// ����� ��������� ����������� (�������� ��������/��������) - ����������
        SpravName : string;
      public
        QuestionCallback : TProc;

        procedure ShowHint(text: string);

        procedure Clear;
        procedure Update;
        procedure AttachControl(name: string; control: TControl);
        procedure AttachEvent(obj: TControl; event: TEvent);
        procedure NextMonth;
        procedure PrevMonth;
        function GetFileName: string;
        function GetSpravFileName: string;
        procedure SetDateBegin(date: string);
        procedure SetDateFinish(date: string);

        function LoadData(filename: string): boolean;
        function LoadSprav(filename: string): boolean;
        procedure LoadSettings;
        procedure SaveData;

        procedure SelectTile(control: TControl);
        procedure SetMode(_mode: string = '');

        procedure onSpravCancel;
        procedure onSpravSelect(data: ISuperObject);
        procedure onSpravRequest(callback: TSpravAnsverEvent; name: string);
        procedure HideSprav;

        procedure onMessClose;
        procedure MessageShow(text: string);

        procedure QuestionShow(text: string);
        procedure onQuestionResult(answ: integer); /// 0- ���, 1 - ��

        function onTaskActivate: ISuperObject;
        procedure onTaskCancel(data: ISuperObject = nil);
        procedure onTaskCreate(data: ISuperObject = nil);

        function onSettingsActivate: ISuperObject;
        procedure onSettingsSave(data: ISuperObject);
        procedure onSettingsCancel;

        function onGetInfoData: ISuperObject;

        /// ������ ��������� �������� � ������ ����������
        procedure onTaskDayLess(sender: TObject);
        procedure onTaskDayMore(sender: TObject);
        procedure onTaskEdit(sender: TObject);
        procedure onTaskDelete(sender: TObject);
        procedure onTaskDeleteConfirm(answ: variant);
        procedure onTaskAddPersone(sender: TObject);
        function onTaskRemovePersone(taskID, workerID: integer): boolean;
        procedure onTaskCopyNext(sender: TObject);
        procedure onTaskCopyFull(sender: TObject);

        function onGetWorkersData: ISuperObject;
        procedure onWorkerCancel;
        procedure onWorkerSave(data: ISuperObject);

        procedure onLocationClick(sender: TObject);
        procedure SelectLocation(id: integer);

        function onLocationActivate: ISuperObject;
        procedure onLocationSave(data: ISuperObject);

        procedure onMissionCreate(brigada, brigader, filename: string);
      end;

var
    AppInterface: TInterface;

implementation

uses uSprav;

{ TInterface }

procedure TInterface.AttachControl(name: string; control: TControl);
begin
    Controls.Add(name, control);
end;
procedure TInterface.AttachEvent(obj: TControl; event: TEvent);
begin
    ActivateEvents.Add(obj, event);
end;


procedure TInterface.Update;
var
    i, j: integer;
    cnt: TControl;       // ������-����, ���� �������� ��� ����������
    data, item: ISuperObject;  // ������ �������� ���, �� ������ ������� �������� ����
    task: ISuperObject;  // ������ ����������� ������� �� data
    layers: TDictionary<integer, TControl>;  /// ������ ����� �������� �����
    hgh: single;

    rect, wrkRect: TRectangle;    // ����������� ������� ����������� ������
    circ : TCircle;      // ������ ���� ������
    img: TImage;         // �������� ���� ������
    lab : TLabel;
begin
    if not AppData.DataLoaded then
    begin
        Controls['buttonBrigada'].Visible   := false;
        Controls['buttonLocations'].Visible := false;
        Controls['buttonSettings'].Visible  := false;
        Controls['buttonSaveData'].Visible  := false;

    end else
    begin
        Controls['buttonBrigada'].Visible   := true;
        Controls['buttonLocations'].Visible := true;
        Controls['buttonSettings'].Visible  := true;
        Controls['buttonSaveData'].Visible  := true;
    end;

    /// ���������� ������ ������� ��������
    for i := Controls['flowLocations'].ControlsCount - 1 downto 0 do
    Controls['flowLocations'].Controls[i].Free;

    data := AppData.GetLocationList;
    for item in data do
    begin
        if item.B['selected']
        then cnt := fAtlas.rLocationSel.Clone(Controls['flowLocations']) as TControl
        else
        begin
            cnt := fAtlas.rLocation.Clone(Controls['flowLocations']) as TControl;
            cnt.OnClick := onLocationClick;
        end;

        cnt.Parent := Controls['flowLocations'];
        cnt.Tag := item.I['id'];
        (cnt.Controls[0] as TLabel).Text := item.S['name'];
    end;


    /// ����������� ������
    (Controls['labelObjName']    as TLabel).Text := AppData.GetObjName + ' ( ���.� ' + AppData.GetZavNum + ' )';
    (Controls['labelObjPlace']   as TLabel).Text := AppData.GetObjPlace;
    (Controls['labelDateBegin']  as TLabel).Text := AppData.GetDateBegin;
    (Controls['labelDateFinish'] as TLabel).Text := AppData.GetDateFinish;

    (Controls['labelFileName']   as TLabel).Text := ExtractFileName(AppData.GetFileName);
    if (Controls['labelFileName'] as TLabel).Text = '' then
       (Controls['labelFileName'] as TLabel).Text := '�� ��������';

    (Controls['labelSpravFileName'] as TLabel).Text := ExtractFileName(AppData.GetSpravFileName);
    if (Controls['labelSpravFileName'] as TLabel).Text = '' then
       (Controls['labelSpravFileName'] as TLabel).Text := '�� ��������';

    (Controls['labelYear']       as TLabel).Text := AppData.CurrYear;
    (Controls['labelMonth']      as TLabel).Text := AppData.CurrMonthName;

    if AppData.isLocationSelected then
    begin
        Controls['buttonDateBegin'].Visible := true;
        Controls['buttonDateFinish'].Visible := true;
    end else
    begin
        Controls['buttonDateBegin'].Visible := false;
        Controls['buttonDateFinish'].Visible := false;
    end;

    /// ����� ��������� ����������
    Controls['Prev'].Visible := AppData.AllowPrev;
    Controls['Next'].Visible := AppData.AllowNext;


    /// ���� ���������� ���� �������� ��� ������ (�������� � ������� ������ � ����� ������)
    /// ����������/������ ���������� ���������� ������� ���
    data := AppData.GetDayData(AppData.GetSelIndex);
    if Assigned(data) then
    begin
        Mode := MODE_INFO;
        Controls['buttonNewTask'].Visible := true;
    end else
    begin
        Mode := MODE_NONE;
        Controls['buttonNewTask'].Visible := false;
    end;


    /// ���������� � ����� ������� ���� ��������� ������
    for i := 1 to 35 do
    begin
        /// �������� ���� ���
        cnt := Controls['Day' + IntToStr( i ) ];

        /// ������ �����������
        for j := cnt.ControlsCount-1 downto 0 do /// ������ ���������� �������. ����� ����������� � ����, ��� ���-�� ��������������
        if not (cnt.Controls[j] is TCircle)
        then cnt.Controls[j].Free;

        cnt.Controls[0].Visible := false;  /// ������ ������, � ������� ��������� ����� ���


        /// ������/������� ��������� �����
        if AppData.GetSelIndex = i then
        begin
            (cnt.Controls[0] as TCircle).Stroke.Color := TAlphaColorRec.Black;
            (cnt.Controls[0] as TCircle).Fill.Color := TAlphaColorRec.Yellow;
            (cnt.Controls[0].Controls[0] as TLabel).TextSettings.FontColor := TAlphaColorRec.Black;
        end else
        begin
            (cnt.Controls[0] as TCircle).Stroke.Color := TAlphaColorRec.Silver;
            (cnt.Controls[0] as TCircle).Fill.Color := TAlphaColorRec.Null;
            (cnt.Controls[0].Controls[0] as TLabel).TextSettings.FontColor := TAlphaColorRec.Darkgrey;
        end;

        /// �������� ����� ������
        data := AppData.GetDayData(i);

        /// ���� ���� - ������������
        if Assigned(data) then
        begin
            /// ���������� ����� � ������� ���
            cnt.Controls[0].Visible := true;
           (cnt.Controls[0].Controls[0] as TLabel).Text := data.S['day'];

            /// ���� ���� ������ �� ���� ����
            if Assigned(data.O['tasks']) then
            begin
                /// ��������� ����� ����� � ������� ����� ����� ������������ ������
                hgh := Min((cnt.Height - 10) / AppData.GetMaxLayers, TASK_LAYER_MAX_HEIGHT);

                layers := TDictionary<integer, TControl>.Create;
                for j := 1 to AppData.GetMaxLayers do
                begin
                    rect := TRectangle.Create(nil);
                    rect.Parent := cnt;
                    rect.Align := TAlignLayout.Bottom;
                    rect.Height := hgh;
                    rect.Fill.Kind := TBrushKind.None;
                    rect.Stroke.Kind := TBrushKind.None;
                    rect.HitTest := false;
                    rect.SendToBack;
                    rect.XRadius := 10;
                    rect.YRadius := 10;
                    rect.Margins.Bottom := 1;

                    layers.Add(j, rect);
                end;

               /// ���������� ������ � ���������� � ��������������� �����
               for task in data.O['tasks'] do
               begin
                   rect := layers[ task.I['layer'] ] as TRectangle;
                   rect.Fill.Kind := TBrushKind.Solid;
                   rect.Fill.Color := AppData.GetKindColor( task.I['WorkTypeID'] );

                   /// ���������� ���������� ����������� �����
                   if task.I['workCount'] > 0 then
                   begin
                        wrkRect := TRectangle.Create(nil);
                        wrkRect.height := 15;
                        wrkRect.width := 20;
                        wrkRect.Fill.Kind := TBrushKind.None;
                        wrkRect.Stroke.Kind := TBrushKind.None;
                        wrkRect.HitTest := false;
                        wrkRect.Align := TAlignLayout.Center;
                        wrkRect.Parent := rect;

                        /// ������ � ������ �������� ���� ������
                        img := TImage.Create(nil);
                        img.Bitmap.Assign( fAtlas.iWorker.MultiResBitmap[0].Bitmap );
                        img.HitTest := false;
                        img.Align := TAlignLayout.Left;
                        img.width := wrkRect.height;
                        img.Parent := wrkRect;

                        lab := TLabel.Create(nil);
                        lab.Text := task.S['workCount'];
                        lab.Align := TAlignLayout.Left;
                        lab.Parent := wrkRect;
                   end;


                   // ��� ������ ���� ������
                   if task.B['first'] then
                   begin
                        rect.Margins.Left := 1; // ����� �� ����������� ����� "���������" �����. ���������

                        /// ������� ������ ��� ����������� ���� ������
                        circ := TCircle.Create(nil);
                        circ.HitTest := false;
                        circ.Width := rect.Height-4;
                        circ.Height := rect.Height-4;
                        circ.Margins.Left := 2;
                        circ.Fill.Color := TAlphaColorRec.White;
                        circ.Stroke.Kind := TBrushKind.None;
                        circ.Align := TAlignLayout.Left;
                        circ.Parent := rect;

                        /// ������ � ������ �������� ���� ������
                        img := TImage.Create(nil);
                        img.Bitmap.Assign( AppData.GetKindIcon( task.I['WorkTypeID'] ) );
                        img.HitTest := false;
                        img.Align := TAlignLayout.Client;
                        img.Margins.Left := 2;
                        img.Margins.Right := 2;
                        img.Margins.Top := 2;
                        img.Margins.Bottom := 2;
                        img.Parent := circ;
                   end;

                   if task.B['last'] then rect.Margins.Right := 1; // ����� �� ����������� ����� "���������" �����. ���������

                   /// ������� �����������, ���� ��� �� ������ ���� ��� ���������� ������� � ���������� ����
                   if not task.B['first']
                   then rect.Corners := rect.Corners - [TCorner.TopLeft, TCorner.BottomLeft];

                   /// ������� �����������, ���� ��� �� ��������� ���� ��� ���������� ������� �� ��������� ����
                   if not task.B['last']
                   then rect.Corners := rect.Corners - [TCorner.TopRight, TCorner.BottomRight];

               end;
            end;
        end
    end;

    /// ��������� ������ ����������, ���� ������� ����� �������������
    if LastMode = MODE_INFO then fInfo.Activate;

    SetMode();
end;

procedure TInterface.Clear;
var
    item: TPair<string, TControl>;
    i: integer;
begin
    for item in Controls do
    begin
        /// ������� ��� ������, ������������ ������
        if Pos('label', String(item.Key)) > 0 then (item.Value as TLabel).Text := '';

        /// ������ ��������� �� �������
        if (item.Key = 'Prev') or (item.Key = 'Next') then item.Value.Visible := false;

        /// ���� ���, ������ ��� ����������
        if Pos('Day', String(item.Key)) > 0 then
        for i := 0 to item.Value.ControlsCount-1 do
            item.Value.Controls[i].Visible := false;

        if (Pos('button', String(item.Key)) > 0) and (item.Key <> 'buttonOpenFile') then
            item.Value.Visible := false;
    end;

end;

function TInterface.GetFileName: string;
begin
    result := AppData.GetFileName;
end;
function TInterface.GetSpravFileName: string;
begin
    result := AppData.GetSpravFileName;
end;

function TInterface.LoadData(filename: string): boolean;
begin
    result := AppData.LoadData(filename);
end;
procedure TInterface.LoadSettings;
begin
    AppData.LoadSettings;
end;

function TInterface.LoadSprav(filename: string): boolean;
begin
    result := AppData.LoadSprav(filename);
end;

procedure TInterface.NextMonth;
begin
    AppData.NextMonth;
    AppData.SetSelIndex( -999 );  // ������� ��������� ���
    Mode := MODE_NONE;
    Update;
end;

procedure TInterface.MessageShow(text: string);
var
    spr, lay: TControl;
begin
    /// �������� �������� ����� ����������� � ������-��������� ��� ����
    if not Controls.TryGetValue(FORM_MESSAGE, spr) then exit;
    if not Controls.TryGetValue(FORM_MAIN, lay) then exit;

    if lay.ControlsCount > 0 then
    lay.Controls[0].Parent := nil;

    /// ��������������
    spr.Parent := lay;
    lay.Align := TAlignLayout.Client;
    lay.Opacity := 0;

    /// ������� ����������
    TAnimator.AnimateFloat(lay, 'opacity', 1, ANIMATION_SPEED);

    /// �������� ����� ������������� ����������� �������
    fMessage.Activate( text );
end;

function TInterface.onGetInfoData: ISuperObject;
begin
    result := AppData.GetDayData;
end;

function TInterface.onGetWorkersData: ISuperObject;
begin
    result := AppData.GetWorkersData;
end;

function TInterface.onLocationActivate: ISuperObject;
begin
    result := AppData.GetLocationData;
end;

procedure TInterface.onLocationClick(sender: TObject);
begin
    AppInterface.SelectLocation((sender as TControl).Tag);
end;

procedure TInterface.onLocationSave(data: ISuperObject);
begin
    AppData.SetLocations(data);
    Update;
end;

procedure TInterface.onMessClose;
var
    spr, lay: TControl;
begin
    /// �������� �������� ������-��������� �����������
    if not Controls.TryGetValue(FORM_MAIN, lay) then exit;

    lay.Align := TAlignLayout.None;

    /// ������� ������
    TAnimator.AnimateFloatDelay(lay, 'Height', 0, ANIMATION_SPEED, ANIMATION_SPEED);
    TAnimator.AnimateFloatDelay(lay, 'Width', 0, ANIMATION_SPEED, ANIMATION_SPEED);
    TAnimator.AnimateFloat(lay, 'opacity', 0, ANIMATION_SPEED);
end;

procedure TInterface.onMissionCreate(brigada, brigader, filename: string);
var
    mis: ISuperObject;
begin
    mis := AppData.CreateMission(brigada, brigader);
    if Assigned(mis) then
    begin
        AppData.SetMissionData(mis);
        AppData.SaveData(filename);  /// ��������� � ����
        AppData.LoadData(filename);  /// ���������

        Update;
    end;
end;

procedure TInterface.onQuestionResult(answ: integer);
begin
    onMessClose;
    if Assigned(QuestionCallback) then QuestionCallback(answ);
end;

function TInterface.onSettingsActivate: ISuperObject;
/// ����� �������� ������ ���� ��������
begin
    result := AppData.GetSettingsData;
end;
procedure TInterface.onSettingsCancel;
begin
    SetMode(MODE_INFO);          /// ������������� �� ������ ����������
end;
procedure TInterface.onSettingsSave(data: ISuperObject);
begin
    AppData.SaveSettings(data);  /// ��������� ��������� ����������
    SetMode(MODE_INFO);          /// ������������� �� ������ ����������
    Update;                      /// �������������� ���������
end;


procedure TInterface.onSpravCancel;
begin
    HideSprav;
end;

procedure TInterface.onSpravRequest(callback: TSpravAnsverEvent; name: string);
/// ����� ����������� � ������� ���������� ��������
var
    spr, lay: TControl;
begin
    /// ����������, ��� ���������� ����������, ����� ����� ������ ������ ���
    SpravCallback := callback;
    SpravName := name;

    /// �������� �������� ����� ����������� � ������-��������� ��� ����
    if not Controls.TryGetValue(FORM_SPRAV, spr) then exit;
    if not Controls.TryGetValue(FORM_MAIN, lay) then exit;

    if lay.ControlsCount > 0 then
    lay.Controls[0].Parent := nil;

    /// ��������������
    spr.Parent := lay;
    lay.Align := TAlignLayout.Client;
    lay.Opacity := 0;
    spr.HitTest := true;

    /// ������� ����������
    TAnimator.AnimateFloat(lay, 'opacity', 1, ANIMATION_SPEED);

    /// �������� ����� ������������� ����������� �������
    fSprav.ShowSprav( AppData.GetSpravData(name) );
end;

procedure TInterface.HideSprav;
var
    spr, lay: TControl;
begin
    /// �������� �������� ������-��������� �����������
    if not Controls.TryGetValue(FORM_MAIN, lay) then exit;
    if not Controls.TryGetValue(FORM_SPRAV, spr) then exit;

    lay.Align := TAlignLayout.None;

    /// ������� ������
    TAnimator.AnimateFloatDelay(lay, 'Height', 0, ANIMATION_SPEED, ANIMATION_SPEED);
    TAnimator.AnimateFloatDelay(lay, 'Width', 0, ANIMATION_SPEED, ANIMATION_SPEED);
    TAnimator.AnimateFloat(lay, 'opacity', 0, ANIMATION_SPEED);
end;

procedure TInterface.onSpravSelect(data: ISuperObject);
begin
    if Assigned( SpravCallback )
    then SpravCallback(SpravName, data);

    SpravCallback := nil;
    SpravName := '';

    HideSprav;
end;

function TInterface.onTaskActivate;
begin

   /// �������� ������ � ����� ��������/�������������
   if fTaskID <> 0
   then result := AppData.GetTaskData( IntToStr(fTaskID) )
   else result := nil;

end;

procedure TInterface.onTaskCancel(data: ISuperObject);
begin
    SetMode(MODE_INFO);
end;

procedure TInterface.onTaskCopyFull(sender: TObject);
begin
    if AppData.TaskCopyFull( (sender as TControl).Tag )
    then AppInterface.Update;
end;

procedure TInterface.onTaskCopyNext(sender: TObject);
begin
    if AppData.TaskCopyNext( (sender as TControl).Tag )
    then AppInterface.Update;
end;

procedure TInterface.onTaskCreate(data: ISuperObject);
begin
    AppData.SetTask(data);
    AppData.UpdateTaskLayers;
    Update;
end;



procedure TInterface.PrevMonth;
begin
    AppData.PrevMonth;
    AppData.SetSelIndex( -999 );  // ������� ��������� ���
    Mode := MODE_NONE;
    Update;
end;

procedure TInterface.QuestionShow(text: string);
var
    spr, lay: TControl;
begin
    /// �������� �������� ����� ����������� � ������-��������� ��� ����
    if not Controls.TryGetValue(FORM_QUESTION, spr) then exit;
    if not Controls.TryGetValue(FORM_MAIN, lay) then exit;

    if lay.ControlsCount > 0 then
    lay.Controls[0].Parent := nil;

    /// ��������������
    spr.Parent := lay;
    lay.Align := TAlignLayout.Client;
    lay.Opacity := 0;

    /// ������� ����������
    TAnimator.AnimateFloat(lay, 'opacity', 1, ANIMATION_SPEED);

    /// �������� ����� ������������� ����� ������� �������
    fQuestion.Activate( text );
end;

procedure TInterface.SaveData;
var
   cnt : TControl;
begin
    if AppData.SaveData then
    if Controls.TryGetValue('iSaveOk', cnt) then
    begin
       cnt.Opacity := 1;
       TAnimator.AnimateFloat(cnt, 'Opacity', 0, ANIMATION_SPEED * 3);
    end;
end;

procedure TInterface.SelectLocation(id: integer);
begin
    AppData.SelectLocation(id);
    Update;
end;

procedure TInterface.SelectTile(control: TControl);
var
    pair: TPair<string, TControl>;
begin
    for pair in Controls do
    begin
        /// ��������� ������ �� ����� ����������� �����
        if pair.Value = control
        then AppData.SetSelIndex( StrToInt(Copy(pair.Key, 4, Length(pair.Key))) );
    end;

    Update;
end;

procedure TInterface.SetDateBegin(date: string);
begin
    AppData.SetDateBegin(date);
    Update;
end;

procedure TInterface.SetDateFinish(date: string);
begin
    AppData.SetDateFinish(date);
    Update;
end;

procedure TInterface.SetMode(_mode: string);
/// �������� �� ���������� ������������ �������
var
    cnt : TControl;
    event: TEvent;
begin
    if _mode <> '' then Mode := _mode;

    // �� ��������� - �������
    if LastMode = Mode then exit;

    // ���� ��� ������� �������� - ������
    if (LastMode <> '') then
    begin
        if Controls.TryGetValue( LastMode, cnt ) then
        begin
            cnt.SendToBack;
            TAnimator.AnimateFloat(cnt, 'Position.X', 100, ANIMATION_SPEED, TAnimationType.&In, TInterpolationType.Linear);
            TAnimator.AnimateFloat(cnt, 'Opacity', 0, ANIMATION_SPEED, TAnimationType.&In, TInterpolationType.Linear);
            LastMode := Mode;
        end;
    end;

    // ���������� ���������
    if Controls.TryGetValue( Mode, cnt ) then
    begin
        /// ����������� � ������� �������, ��� ����� ������������
        cnt.Parent := Controls['layWork'];
        cnt.BringToFront;

        /// �������������� �������� ����� ����������
        cnt.Position.X := 100;
        cnt.Opacity := 0;

        /// ��������� ��������
        TAnimator.AnimateFloat(cnt, 'Position.X', 0, ANIMATION_SPEED, TAnimationType.&In, TInterpolationType.Linear);
        TAnimator.AnimateFloat(cnt, 'Opacity', 1, ANIMATION_SPEED, TAnimationType.&In, TInterpolationType.Linear);
        LastMode := Mode;

        /// �������� ������� ���������, ���� ����
        if ActivateEvents.TryGetValue(cnt, event) then event;
    end;
end;



procedure TInterface.ShowHint(text: string);
var
    cnt : TControl;
begin
    if Controls.TryGetValue('labelHint', cnt) then
    (cnt as TLabel).Text := text;
end;

procedure TInterface.onTaskDayLess(sender: TObject);
/// ���������� �������� ���� ������.
/// �� ID ���������� � ���� TAG ����������� ����������.
begin
    if AppData.TaskDayLess( (Sender as TControl).Tag ) then Update;
end;

procedure TInterface.onTaskDayMore(sender: TObject);
begin
    if AppData.TaskDayMore( (Sender as TControl).Tag ) then Update;
end;

procedure TInterface.onTaskDelete(sender: TObject);
begin
    /// ������������� ����������-������� ��������� ������
    QuestionCallback := onTaskDeleteConfirm;
    fTaskID := (Sender as TControl).Tag;
    QuestionShow('�� ������������� ������ ������� ������?');
end;
procedure TInterface.onTaskDeleteConfirm(answ: variant);
begin
    if answ = 0 then exit; /// 0 = ���, 1 = ��

    if AppData.TaskDelete( fTaskID ) then
    begin
        AppData.UpdateTaskLayers;
        fTaskID := 0;
        Update;
    end;
end;

procedure TInterface.onTaskEdit(sender: TObject);
begin
    fTaskid := (Sender as TControl).Tag;
    SetMode(MODE_TASK);
end;

procedure TInterface.onTaskAddPersone(sender: TObject);
begin
    fTaskID := (Sender as TControl).Tag;

end;

function TInterface.onTaskRemovePersone(taskID, workerID: integer): boolean;
begin
    result := false;
    if AppData.RemoveWorker( taskID, workerID ) then
    begin
        result := true;
        AppInterface.Update;
    end;
end;


procedure TInterface.onWorkerCancel;
begin
    AppInterface.SetMode(MODE_INFO);
end;

procedure TInterface.onWorkerSave(data: ISuperObject);
begin
    AppData.SetWorkers(data);
    SetMode(MODE_INFO);
    Update;
end;

initialization
    AppInterface := TInterface.Create;
    AppInterface.Controls := TDictionary<string,TControl>.Create;
    AppInterface.ActivateEvents := TDictionary<TControl,TEvent>.Create;
    AppInterface.Mode := MODE_NONE;
    AppInterface.LastMode := '';

finalization
    AppInterface.ActivateEvents.Free;
    AppInterface.Controls.Free;
    AppInterface.Free;

end.
