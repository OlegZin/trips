unit uData;

interface

uses
    superobject, System.UITypes, FMX.Graphics, System.Types,
    SysUtils, DateUtils, Math, StrUtils, uConst;

type
    TData = class
      private
        fData: ISuperObject;     /// ������� ������ (������, �����������)
        fSettings: ISuperObject; /// ��������� ����������� (���� �� ����� �����, ������)
        fFilename : string;      /// ������� �������� ������� ����
        fSpravFilename : string; /// ������� �������� ���� ������������

        function CurrMonth: string;
        function FirstMonth: string;
      public
        function LoadData(filename: string): boolean;
        function LoadSprav(filename: string): boolean;
        procedure LoadSettings;

        function SaveData(filename : string = ''): boolean;
        function DataLoaded: boolean;

        procedure SelectLocation(id: integer);
        function isLocationSelected: boolean;
        function GetLocationID: integer;
        procedure SetLocationID(id: integer);

        function GetFileName: string;
        function GetSpravFileName: string;
        function GetObjName: string;
        function GetObjPlace: string;
        function GetZavNum: string;
        function GetDateBegin: string;
        function GetDateFinish: string;
        function isSetDateFinish: boolean;

        procedure SetDateBegin(date: string);
        procedure SetDateFinish(date: string);

        function CurrMonthName: string;
        function CurrYear: string;
        function GetTileDate: TDate;

        function AllowPrev: boolean;
        function AllowNext: boolean;

        procedure PrevMonth;
        procedure NextMonth;

        function GetDayData(index: integer = -1): ISuperObject;
        function GetLocationList: ISuperObject;

        procedure SetCurrDate(date: TDate);

        function GetNewTaskID: integer;
        function GetTaskData(id: string): ISuperObject;  /// �������� ������ ������
        procedure SetTask(data: ISuperObject);           /// ������/��������� ������ (data �������� ���� ID)
        procedure UpdateTaskLayers;                      /// ������������� �������� layer ���� ����� ���
                                                         /// ����������� ����������� �������������� ����� � ����������

        function GetSpravData(name: string): ISuperObject;  /// ��������� ������ ����������� � ��������� ������

        /// ������ ����� - �������� � ���� �� ��������� ���� �������� ��������������� ������
        ///    ����� - ����� ����, ������������ � ����������. ���� ������� ������������ �����
        ///    ���������� � ������������, �� ������ ������ ����� ��������� � ������ ���� ������.
        ///    � ���� ������, ������ ������ ����� �������� �� ���������� ����� (� ���������� ������������)
        procedure SetSelIndex(index: integer); /// ������������� ������ �������� ����������� �����
        function GetSelIndex: integer;         /// �������� ������ �������� ����������� �����

        function GetMaxLayers: Integer;

        function GetSettingsData: ISuperObject;
        procedure SaveSettings(data: ISuperObject);
        function GetKindColor(id: integer): TColor;
        function GetKindIcon(id: integer): TBitmap;

        /// ����� ������� ���������� ���������� �������
        function TaskDayLess(id: integer): boolean;  /// ��������� ������������ ������ �� 1 ����, �� �� ������ 1 ���
        function TaskDayMore(id: integer): boolean;  /// ����������� ������������ ������ �� 1 ����
        function TaskDelete(id: integer): boolean;  /// ����������� ������������ ������ �� 1 ����

        function AddWorker(taskID: integer; data: ISuperObject): boolean;
                                                    /// ��������� ��������� �� ��������� ������ �� ������� ����
        function RemoveWorker(taskID, workerID: integer): boolean;
                                                    /// ������� ��������� � ��������� ������ �� ������� ����
        function TaskCopyNext(taskID: integer): boolean; // �������� ������ ������� � �������� ��� �� ���������
        function TaskCopyFull(taskID: integer): boolean; // �������� ������ ������� � �������� ��� �� ����� ������

        function GetWorkersData: ISuperObject;
        function GetNewWorkerID: integer;
        procedure SetWorkers(data: ISuperObject);

        function GetLocationData: ISuperObject;
        procedure SetLocations(data: ISuperobject);
        function GetNewLocation(ObjectName, ObjectPlace, ZavNum: string; ObjectPlaceID: integer): ISuperObject;
        function GetNewLocationID: integer;
        function CreateMission(brigada, brigader: string): ISuperObject;

        procedure SetMissionData(data: ISuperObject);
   end;

var
   AppData : TData;

implementation

{ TData }

uses uSettings;

function TData.GetDayData(index: integer): ISuperObject;
///    ����� �������� ������ ��� ������������ ���� Work.CurrFrameDate.
///    ��� index = 1 - ��������� � Work.CurrFrameDate, 2 = Work.CurrFrameDate+1 ���� � �.�.
var
    date: TDate;
    datestr, strBrigada, dayID: string;
    task, worker, brigada: ISuperObject;
begin
    result := nil;

    /// ���� �� ������� ���� ������ ������ - ������ �� ����������
    if not Assigned(fData) or not Assigned(fData.O['Work.CurrFrameDate']) or (fData.S['Work.CurrFrameDate'] = '') then exit;
    /// ���� �� ������� ������� - ���������� ������
    if not isLocationSelected then exit;

    if index = -1 then index := GetSelIndex;

    /// �������� �� ������� ���� ����������� �����
    date := IncDay( StrToDate(fData.S['Work.CurrFrameDate']), index-1 );
    datestr := FormatDateTime( 'dd.mm.yyyy', date );

    /// �� ����� ���������� ������, ���� ���� ������� �� ������� ��������� � �������� ����
    if (GetDateFinish <> '') and ( date > StrToDate(GetDateFinish)) then exit;
    if (GetDateBegin <> '') and ( date < StrToDate(GetDateBegin)) then exit;

    /// �� ����� ���������� ������, ���� ���� �� ������
    if (GetDateFinish = '') and (GetDateBegin = '') then exit;

    /// ���������
    result := SO();

    result.I['day'] := DayOf( date );  /// ����� ���
    result.S['month'] := FormatDateTime( 'mmmm', date );  /// �������� ������
    dayID := IntTostr(YearOf( date ) * 10000 + MonthOf( date ) * 100 + DayOf( date ));

    /// ���������� ������ � ��������� ������ � ������� �����, ���������� � ���� ����
    If Assigned(fData.O['tasks']) then
    for task in fData.O['tasks'] do

    /// ���� ������� ���� �������� �� ��������� ����� ������
    if (StrToDate(task.S['DateStart']) <= date) and (StrToDate(task.S['DateFinish']) >= date) and
    /// � ������ ��������� � �������� ���������� �������
      (task.I['LocationID'] = GetLocationID)
    then
    begin
        brigada := SA([]);

        /// ���������� ���� ���������� � ���������, ��������� �� ��� �� ������ �� ���� ����
        if assigned( fData.O['Workers'] ) then
        for worker in fData.O['Workers'] do
        if assigned(task.O['Brigada.'+worker.S['id']+'.'+dayID]) and
            (task.I['Brigada.'+worker.S['id']+'.'+dayID] = 1)
        then
            brigada.AsArray.Add(SO('{name:"'+worker.S['name']+'",id:'+worker.S['id']+'}'));


        /// ��������� ������� � ������ �����
        result['tasks[]'] := SO(
        '{'+
           'id:' + task.S['ID'] + ','+  // �������� �� ���� ���� ���� ������ ������
           'first:' + ifthen( StrToDate(task.S['DateStart']) = date, 'true', 'false' ) + ','+  // �������� �� ���� ���� ���� ������ ������
           'last:' + ifthen( StrToDate(task.S['DateFinish']) = date, 'true', 'false' ) + ','+  // �������� �� ���� ���� ���� ��������� ������
           'layer:' + task.S['layer'] + ','+              // �� ����� ���� ���������� ������
           'WorkTypeID:' + task.S['WorkTypeID'] + ','+    // ��� ������
           'WorkType:' + task.S['WorkType'] + ','+        // ��� ������
           'brigada:' + brigada.AsJSon + ','+             // ������ ������� �� ���� ����
           'workCount:' + IntToStr(brigada.AsArray.Length) + ','+             // ������ ������� �� ���� ����
        '}');
    end;
end;


function TData.GetDateBegin: string;
begin
    result := '';

    if not isLocationSelected or
       not Assigned(fData.O['Locations']) or
       not Assigned(fData.O['Locations.'+IntToStr(GetLocationID)])
    then exit;

    result := fData.S['Locations.'+IntToStr(GetLocationID)+'.StartDate'];
end;

function TData.GetDateFinish: string;
begin
    result := '';

    if not isLocationSelected or
       not Assigned(fData.O['Locations']) or
       not Assigned(fData.O['Locations.'+IntToStr(GetLocationID)])
    then exit;

    result := fData.S['Locations.'+IntToStr(GetLocationID)+'.FinishDate'];
end;


function TData.GetFileName: string;
begin
    result := fFilename;
end;
function TData.GetSpravFileName: string;
begin
    result := fSpravFilename;
end;

function TData.GetKindColor(id: integer): TColor;
begin
    /// ���� ������������ ��������� ��� ������� ����
    if Assigned(fSettings.O[IntToStr(id)])
    then result := TColor(fSettings.I[IntToStr(id)+'.color'])
    else result := TAlphaColorRec.Lightskyblue;
end;

function TData.GetKindIcon(id: integer): TBitmap;
var
    size: TSizeF;
begin
    size.cx := 32;
    size.cy := 32;
    /// ���� ������������ ��������� ��� ������� ����
    if Assigned(fSettings.O[IntToStr(id)])
    then result := fSettingsForm.ImageList1.Bitmap(size, fSettings.I[IntToStr(id)+'.icon'])
    else result := fSettingsForm.ImageList1.Bitmap(size, fSettings.I['0']);
end;

function TData.GetLocationData: ISuperObject;
begin
    result := nil;

    if not Assigned( fData ) or not Assigned( fData.O['Locations'] )
    then result := SO()
    else result := fData.O['Locations'].Clone;
end;

function TData.GetLocationID: integer;
begin
    result := 0;

    if not isLocationSelected then exit;

    result :=  fData.I['Work.SelLocationID'];
end;

procedure TData.SetLocationID(id: integer);
begin
    fData.I['Work.SelLocationID'] := id;
end;


procedure TData.SetLocations(data: ISuperobject);
var
    loc, task: ISuperObject;
    toDel: array of string;
    i : integer;
begin
    if not Assigned( fData ) then exit;

    /// ��������� ������� ��������� ���������
    for loc in data do
    if loc.B['Deleted'] then  /// ���� ������� �������
    begin
        /// ������ � �� ������, ���� ����
        if Assigned(fData.O['tasks']) then
        for task in fData.O['tasks'] do
        if task.I['LocationID'] = loc.I['id'] then
        fData.Delete('tasks.'+task.S['ID']);

        /// � ���� ������� �������� �� ��������.
        /// ���� �������� �� ������ � ��� ���� ���������, �� ������� "for loc in data do"
        /// ��������� �����������
        SetLength(toDel, Length(toDel)+1);
        toDel[High(toDel)] := loc.S['id'];
    end;

    for I := 0 to High(toDel) do
      data.Delete( toDel[i] );

    fData.O['Locations'] := data;
end;

function TData.GetLocationList: ISuperObject;
var
    loc: ISuperObject;
begin
    result := SA([]);

    if not Assigned( fData ) or not Assigned( fData.O['Locations'] ) then exit;

    for loc in fData.O['Locations'] do
    if GetLocationID = loc.I['id']
    then result.AsArray.Add( SO('{id: '+loc.S['id']+', name:"'+loc.S['ZavNum']+'", selected: true}') )
    else result.AsArray.Add( SO('{id: '+loc.S['id']+', name:"'+loc.S['ZavNum']+'", selected: false}') );

end;

function TData.GetMaxLayers: Integer;
begin
    result := fData.I['Locations.'+IntToStr(GetLocationID)+'.LayerCount'];
end;

function TData.GetNewLocation(ObjectName, ObjectPlace, ZavNum: string; ObjectPlaceID: integer): ISuperObject;
begin
    result := SO(LOCATION_SHABLON);
    result.I['id'] := GetNewLocationID;
    result.S['ObjectName'] := ObjectName;
    result.S['ObjectPlace'] := ObjectPlace;
    result.I['ObjectPlaceID'] := ObjectPlaceID;
    result.S['ZavNum'] := ZavNum;
end;

function TData.GetNewLocationID: integer;
begin
    result := fData.I['Base.NextLocID'];
    fData.I['Base.NextLocID'] := fData.I['Base.NextLocID'] + 1;
end;

function TData.GetNewTaskID: integer;
begin
    if not Assigned(fData.O['Work.TaskID'])
    then fData.I['Work.TaskID'] := 1;

    result := fData.I['Work.TaskID'];

    fData.I['Work.TaskID'] := fData.I['Work.TaskID'] + 1;
end;

function TData.GetNewWorkerID: integer;
begin
    if not Assigned(fData.O['Work.NewWorkerID'])
    then fData.I['Work.NewWorkerID'] := 1000000;

    result := fData.I['Work.NewWorkerID'];

    fData.I['Work.NewWorkerID'] := fData.I['Work.NewWorkerID'] + 1;
end;

function TData.AddWorker(taskID: integer; data: ISuperObject): boolean;
/// data - ������ ���������, ������� �� ����������� Sprav.Workers
var
    dayID: string;
    currdata: TDate;
begin
    result := false;
    currdata := GetTileDate;
    dayID := IntToStr(YearOF(currdata) * 10000 + MonthOF(currdata) * 100 + DayOf(currdata));

    if Assigned(fData.O['tasks.'+IntToStr(taskID)]) then
    begin
        fData.O['tasks.'+IntToStr(taskID)+'.Brigada.'+data.S['id']] := SO('{'+dayID+':1}');
        result := true;
    end;
end;

function TData.RemoveWorker(taskID, workerID: integer): boolean;
/// data - ������ ���������, ������� �� ����������� Sprav.Workers
var
    dayID: string;
    currdata: TDate;
begin
    result := false;
    currdata := GetTileDate;
    dayID := IntToStr(YearOf(currdata) * 10000 + MonthOF(currdata) * 100 + DayOf(currdata));

    if Assigned(fData.O['tasks.'+IntToStr(taskID)]) then
    begin
        fData.I['tasks.'+IntToStr(taskID)+'.Brigada.'+IntToStr(workerID)+'.'+dayID] := 0;
        result := true;
    end;
end;


function TData.AllowNext: boolean;
begin
    result := false;

    if not Assigned( fData ) or not Assigned( fData.O['Work.CurrDate'] ) or (fData.S['Work.CurrDate'] = '') or (GetDateBegin = '') then exit;

    /// ���� �� �����������
    if GetDateFinish = '' then
    begin
        result := true;
        exit;
    end;

    /// ������� ����� ���� ��������� ����
    result := MonthOf(StrToDate(fData.S['Work.CurrDate'])) < MonthOf(StrToDate(GetDateFinish));
end;

function TData.AllowPrev: boolean;
begin
    result := false;

    if not Assigned( fData ) or not Assigned( fData.O['Work.CurrDate'] ) or (fData.S['Work.CurrDate'] = '') or (GetDateBegin = '') then exit;

    /// ������� ����� ������ ��������� ����
    result := StrToDate( fData.S['Work.CurrDate'] ) > StrToDate( GetDateBegin );
end;

procedure TData.SetTask(data: ISuperObject);
/// ����������/���������� ������
begin
    /// ���� ��� ����� ������
    if not Assigned(fData.O['tasks.'+data.S['ID']]) then
    begin
        /// �������������� ��������� ����� ������ ������� ��������� ����
        data.S['DateStart'] := DateToStr( GetTileDate );
        data.S['DateFinish'] := DateToStr( GetTileDate );
        data.I['LocationID'] := GetLocationID; // ����������� � ������� ��������� �������
    end;

    if not Assigned(fData.O['tasks'])
    then fData.O['tasks'] := SO('{}');

    fData.O['tasks.'+data.S['ID']] := data;
end;

procedure TData.SetWorkers(data: ISuperObject);
var
    pers, task: ISuperobject;
begin
    /// �������� ����������� ������ ������ �������
    fData.O['Workers'] := data.Clone;

    /// ���������, ���� ���� ��������� ���������,
    /// ������� �� �� ���� �����
    for pers in fData.O['Workers'] do
    if pers.B['isDel'] then
    begin
        for task in fData.O['tasks'] do
        if Assigned(task.O['Brigada.'+pers.S['id']])
        then task.Delete( 'Brigada.'+pers.S['id'] );
    end;
end;

function TData.TaskCopyFull(taskID: integer): boolean;
begin
    result := false;

end;

function TData.TaskCopyNext(taskID: integer): boolean;
var
    dayID: string;
    nextdayID: string;
    currdata: TDate;
    worker: ISuperObject;
    value : integer;
begin
    result := false;
    currdata := GetTileDate;
    dayID := IntToStr(YearOf(currdata) * 10000 + MonthOF(currdata) * 100 + DayOf(currdata));
    currdata := IncDay(currdata,1);
    nextdayID := IntToStr(YearOf(currdata) * 10000 + MonthOF(currdata) * 100 + DayOf(currdata));

    if not Assigned(fData.O['tasks.'+IntToStr(taskID)]) then exit;

    /// ���������� ���� ����������
    for worker in fData.O['Workers'] do
    /// ���� �� ������� ��������� �� ������� ���� ���� ������ �����������
    if Assigned( fData.O['tasks.'+IntToStr(taskID)+'.Brigada.'+worker.S['id']+'.'+dayID] ) then
    begin
        // ����� ����������� ����� ��������� �� ��������� ����
        fData.O['tasks.'+IntToStr(taskID)+'.Brigada.'+worker.S['id']+'.'+nextdayID] :=
            fData.O['tasks.'+IntToStr(taskID)+'.Brigada.'+worker.S['id']+'.'+dayID].Clone;
        result := true;
    end;
end;

function TData.TaskDayLess(id: integer): boolean;
/// ��������� �������� ���� ������ �� 1 ����, ���� �� ������ ��������� ����
var
    DateStart, DateFinish: TDate;
begin
    result := false;

    /// ���������� �� ����� ������?
    if not Assigned( fData.O['tasks.'+IntToStr(id)] ) then exit;

    DateStart := StrToDate( fData.S['tasks.'+IntToStr(id)+'.DateStart'] );
    DateFinish := StrToDate( fData.S['tasks.'+IntToStr(id)+'.DateFinish'] );

    /// ��������� ������ ������
    if DateStart = DateFinish then exit;

    fData.S['tasks.'+IntToStr(id)+'.DateFinish'] := DateToStr( IncDay( DateFinish, -1 ) );

    UpdateTaskLayers;

    result := true;
end;

function TData.TaskDayMore(id: integer): boolean;
/// ��������� �������� ���� ������ �� 1 ����, ���� �� ������ ��������� ����
var
    DateStart, DateFinish: TDate;
    setTotal: boolean;
begin
    result := false;

    /// ���������� �� ����� ������?
    if not Assigned( fData.O['tasks.'+IntToStr(id)] ) then exit;

    DateStart := StrToDate( fData.S['tasks.'+IntToStr(id)+'.DateStart'] );
    DateFinish := StrToDate( fData.S['tasks.'+IntToStr(id)+'.DateFinish'] );

    /// ����������� ������ �������� ���� ������������ ������
    if Assigned(fData.O['Base.FinishDate']) and (DateFinish >= StrToDate(fData.S['Base.FinishDate'])) then exit;

    fData.S['tasks.'+IntToStr(id)+'.DateFinish'] := DateToStr( IncDay( DateFinish, 1 ) );

    UpdateTaskLayers;

    result := true;
end;

function TData.TaskDelete(id: integer): boolean;
/// ������� ������ � ��������� id
begin
    result := true;
    fData.Delete('tasks.'+IntToStr(id));
    UpdateTaskLayers;
end;

procedure TData.UpdateTaskLayers;
/// ����� ����������� ����� �� "�����", ����� ��� ������� �������������� �
/// ����������. ������, �������������� �� ���� ���� ������ ����� ������ �������� layer � �������� � �������
///    ��������:
///    - ���������� ��� ������ � �������� �������� layer
///    - ���������� ��� ������
///      - ��� �������(�) ���� ��������� ������ ���������� � ���� �� ������
///      - �������� ��� �������� layer ���� ����� (���� ����������� - ������ ��� ���������� � ��� layer �������� ������)
///      - �������� ���������� ���������� �������� ����� � 0 � ����������� ������ T
var
    maxLayer, freeLayer: integer;
    mainTask, task, layers: ISuperObject;
    item: TSuperAvlEntry;
begin

    if not Assigned( fData['tasks'] ) then exit; // ��� �����

    maxLayer := 0;

    for task in fData['tasks'] do          // ���������� ������ �� �����
        if task.I['LocationID'] = GetLocationID
        then task.I['layer'] := 0;

    fData.I['Locations.'+IntToStr(GetLocationID)+'.LayerCount'] := 0;

    for mainTask in fData['tasks'] do      // ��� ������ ������
    if mainTask.I['LocationID'] = GetLocationID then
    begin

        // �������������� ������ ��������� ������� �����
        layers := SO('{"1":false,"2":false,"3":false,"4":false,"5":false,"6":false,"7":false,"8":false,"9":false}');
        freeLayer := 10;

        for task in fData['tasks'] do      // ���������� ��� ���������
        if task.I['LocationID'] = GetLocationID then
        begin

            if (task = mainTask) then Continue;
                                           // �������������� � ��� �� �����
            if
             (/// ����������� �� ��������� ���� (���� � ����� �������)
              ((StrToDate(task.S['DateStart']) >= StrToDate(mainTask.S['DateStart'])) and
               (StrToDate(task.S['DateStart']) <= StrToDate(mainTask.S['DateFinish']))) or
              /// ����������� �� �������� ���� (���� � ����� �������)
              ((StrToDate(task.S['DateFinish']) >= StrToDate(mainTask.S['DateStart'])) and
               (StrToDate(task.S['DateFinish']) <= StrToDate(mainTask.S['DateFinish']))) or
              /// ����������� � ����������� (����������� ������ ������� � ��� �������)
              ((StrToDate(task.S['DateStart']) <= StrToDate(mainTask.S['DateStart'])) and
               (StrToDate(task.S['DateFinish']) >= StrToDate(mainTask.S['DateFinish'])))
              ) then
                                           // � �������� ����� �������� ����
            if   task.I['layer'] > 0
            then layers.B[ task.S['layer'] ] := true;
        end;

        /// ���������� �������� ����� � ���� ����������� (��� ������� ������) � ������������ (��� ������������ ����������)
        for item in layers.AsObject do
        begin
            /// ��������� ����, ���� ����������� �� ���������
            if not item.Value.AsBoolean then freeLayer := Min( freeLayer, StrToInt(item.Name));
            /// ������� ����, ���� ������������ �� �������
            if item.Value.AsBoolean then maxLayer := Max( maxLayer, StrToInt(item.Name));
        end;

        /// ����� � ���������� ���������� ������������ ��������� ������� ����.
        /// � ���������� ��� �������� ����� �������������� ��� ���������� ����������
        /// ��� ���������� ������ ������ ���� � ������ ���
        fData.I['Locations.'+IntToStr(GetLocationID)+'.LayerCount'] := max( fData.I['Locations.'+IntToStr(GetLocationID)+'.LayerCount'], Max( maxLayer, freeLayer));

        /// ������ �������� ���� ������� ������ � ����� ���������...
        mainTask.I['layer'] := freeLayer;
    end;

end;

function TData.CreateMission(brigada, brigader: string): ISuperObject;
begin
    result := SO(BASE_SHABLON);
    result.S['BrigadaName'] := brigada;
    result.S['Brigader'] := brigader;
end;

function TData.CurrMonth: string;
begin
    result := fData.S['Work.CurrMonth'];
end;

function TData.CurrMonthName: string;
begin
    result := '';

    if not Assigned( fData ) or not Assigned( fData.O['Work.CurrMonthName'] ) or (fData.S['Work.CurrMonthName'] = '') then exit;

    result := fData.S['Work.CurrMonthName'];
end;

function TData.GetObjName: string;
begin
    result := '';
    
    if not isLocationSelected then exit;
    
    result := fData.S['Locations.'+IntToStr(GetLocationID)+'.ObjectName'];
end;

function TData.GetObjPlace: string;
begin
    result := '';

    if not isLocationSelected then exit;

    result := fData.S['Locations.'+IntToStr(GetLocationID)+'.ObjectPlace'];
end;

function TData.GetSelIndex: integer;
begin
    result := 0;

    if not Assigned( fData ) then exit;

    result := fData.I['Work.CurrTileIndex'];
end;



function TData.GetSettingsData: ISuperObject;
/// ����� �������� ������ ���� ��������
var
    item: ISuperObject;
begin

    /// ���������� ���������� ����� ����� � ������ � ������ �������� ������������� ��������
    if Assigned(fData.O['Sprav.WorkTypes']) then
    for item in fData.O['Sprav.WorkTypes'] do
    begin

        if not Assigned(fSettings.O[ item.S['id'] ]) then
        fSettings[ item.S['id'] ] := SO('{id: '+item.S['id']+',name:"'+item.S['name']+'", color: '+IntToStr(TAlphaColorRec.Lightskyblue)+', icon: 0}');

    end;

    result := fSettings;

end;
function TData.SaveData(filename : string): boolean;
/// � ������� ������ ����� �������� ��� ����������� ����������, ����� ������� ������������
var
    part: ISUperobject;
begin
    result := false;
    if not assigned(fData) then exit;

    part := fData.Clone;
    part.Delete('Sprav');

    part.SaveTo( ifthen( filename <> '', filename, fFileName) );

    result := true;
end;

procedure TData.SaveSettings(data: ISuperObject);
/// ��������� ������� ��������� �����������
begin
    data.SaveTo( ExtractFilePath(paramstr(0)) + SETTINGS_FILE_NAME, false);
end;




function TData.GetSpravData(name: string): ISuperObject;
/// �������� � ���, ��� ��������� ����������� ����� ���� �������������
///    � ���������� ��� ������� Sprav.
///    ��������, Workers. ��� ������� ������.
begin
    if assigned(fData) and assigned(fData.O['Sprav']) and assigned(fData.O['Sprav.'+name])
    then result := fData.O['Sprav.'+name];

    if assigned(fData) and assigned(fData.O[name])
    then result := fData.O[name];

    if not Assigned(result) then result := SO();
end;

function TData.GetTaskData(id: string): ISuperObject;
begin
    result := fData.O['tasks.'+id];
end;

function TData.GetTileDate: TDate;
begin
    result :=
        IncDay(
            StrToDate(fData.S['Work.CurrFrameDate']),
            fData.I['Work.CurrTileIndex']-1
        )
end;

function TData.GetWorkersData: ISuperObject;
var
    pers: ISuperObject;
begin
    if not assigned(fData) or not assigned(fData.O['Workers'])
    then result := SA([])
    else result := fData.O['Workers'].Clone;  /// ����� ���������� �������

    /// ��������� ���������
    for pers in result do
    if pers.I['id'] = fData.I['Base.BrigaderID'] then
    pers.B['isBrigadir'] := true;
end;

function TData.GetZavNum: string;
begin
    result := '';
    
    if not isLocationSelected then exit;

    result := fData.S['Locations.'+IntToStr(GetLocationID)+'.ZavNum'];
end;

function TData.isLocationSelected: boolean;
begin
    result := Assigned(fData) and Assigned(fData.O['Work.SelLocationID']) and (fData.I['Work.SelLocationID'] <> 0);
end;

function TData.isSetDateFinish: boolean;
begin
    result := Assigned( fData.O['Base.FinishDate'] );
end;

function TData.CurrYear: string;
begin
    result := '';

    if not Assigned( fData ) or not Assigned( fData.O['Work.CurrDate'] ) or (fData.S['Work.CurrDate'] = '') then exit;

    result := IntToStr(YearOf(StrToDate(fData.S['Work.CurrDate'])));
end;

function TData.DataLoaded: boolean;
begin
    result := fFilename <> '';
end;

function TData.FirstMonth: string;
begin
    result := fData.S['Work.FirstMonth'];
end;

function TData.LoadData(filename: string): boolean;
var
    date: TDate;
    part: ISuperObject;
begin

    result := false;
    fFileName := '';

    if not FileExists(filename) then exit;

    /// �������� ������� ������
    try
        /// ��������� ����������� ���� ����
        if assigned(fData) and assigned(fData.O['Sprav']) then part := fData.O['Sprav'].clone;

        fData := TSuperObject.ParseFile( filename, false);
        fFileName := filename;

        /// ��������������� �����������
        if assigned(part) then fData.O['Sprav'] := part.clone;
    except
    end;

    result := Assigned(fData);

end;

procedure TData.LoadSettings;
begin
    /// �������� ������ ��������,���� ����
    if FileExists( ExtractFilePath(paramstr(0)) + SETTINGS_FILE_NAME )
    then fSettings := TSuperObject.ParseFile( ExtractFilePath(paramstr(0)) + SETTINGS_FILE_NAME, false)
    else fSettings := SO();
end;

function TData.LoadSprav(filename: string): boolean;
var
    date: TDate;
    part: ISuperObject;
begin

    result := false;
    fSpravFilename := '';

    if not FileExists(filename) then exit;

    if not Assigned(fData) then fData := SO();

    /// �������� ������� ������
    try
        fData.O['Sprav'] := TSuperObject.ParseFile( filename, false);
        fSpravFilename := filename;
    except
    end;

    result := Assigned(fData);

end;

procedure TData.NextMonth;
begin
    SetCurrDate( IncMonth( StrToDate(fData.S['Work.CurrDate']), 1 ) );
end;

procedure TData.PrevMonth;
begin
    SetCurrDate( IncMonth( StrToDate(fData.S['Work.CurrDate']), -1 ) );
end;

procedure TData.SelectLocation(id: integer);
var
   date: TDate;
begin
    if not Assigned(fData.O['Locations']) or
       not Assigned(fData.O['Locations.'+IntToStr(id)])
    then exit;

    if not Assigned(fData.O['Work'])
    then fData.O['Work'] := SO();

    SetLocationID(id);

    /// ������ ��������� ����
    if Assigned(fData.O['Locations.'+IntToStr(id)+'.StartDate']) and
      (fData.S['Locations.'+IntToStr(id)+'.StartDate'] <> '')
    then date := StrToDate(fData.S['Locations.'+IntToStr(id)+'.StartDate'])
    else
    begin
        date := Now;
        fData.S['Locations.'+IntToStr(id)+'.StartDate'] := DateToStr(date);
    end;

    fData.I['Work.FirstDay']       := DayOf( date );
    fData.I['Work.FirstMonth']     := MonthOf( date );
    fData.I['Work.FirstYear']      := YearOf( date );

    /// ������ �������� ���������� ������
    SetCurrDate( StartOfTheMonth(date) );

    /// ������ �������� ����
    if Assigned(fData.O['Locations.'+IntToStr(id)+'.FinishDate']) and
       (fData.S['Locations.'+IntToStr(id)+'.FinishDate'] <> '') then
    begin
        date := StrToDate(fData.S['Locations.'+IntToStr(id)+'.FinishDate']);
        fData.I['Work.EndYear']        := YearOf( date );
        fData.I['Work.EndMonth']       := MonthOf( date );
        fData.I['Work.EndDay']         := DayOf( date );
    end else
    begin
        fData.I['Work.EndYear']        := 0;
        fData.I['Work.EndMonth']       := 0;
        fData.I['Work.EndDay']         := 0;
    end;
end;

procedure TData.SetMissionData(data: ISuperObject);
/// ����������� ������ ������������, �� ��������� ����������� � ������ ������ �����������
var
    buf: ISuperObject;
begin
    buf := SO();
    buf.O['Base'] := data;
    buf.O['Sprav'] := fData.O['Sprav'].Clone;
    fData := buf.Clone;
end;

procedure TData.SetCurrDate(date: TDate);
begin
    /// ������ ������� ���� (������)
    fData.S['Work.CurrDate']       := DateToStr(date);
    fData.S['Work.CurrMonthName']  := FormatDateTime('mmmm', date);

    /// ������ ���� �������� ������ "������" - ��������� ����������� ��
    /// ���� ������ �������� ������, ���� ���� ���� ������ ������, ���� ��
    /// � ������������.
    /// ������������ � ��������� ���������� ������ ������� ��������� ����
    /// ����������� ������.
    fData.S['Work.CurrFrameDate']  := FormatDateTime('dd.mm.yyyy',IncDay(StartOfTheMonth(date), - DayOfTheWeek( StartOfTheMonth(date)-1 )));
end;

procedure TData.SetDateBegin(date: string);
/// ������������� �������� ����, ���� ��� ���� ���������
var
    task : ISuperObject;
begin
    if  (GetDateFinish <> '') and (StrToDate(date) > StrToDate( GetDateFinish )) then exit;

    fData.S['Locations.'+IntToStr(GetLocationID)+'.StartDate'] := date;

    if not Assigned(fData.O['tasks']) then exit;

    /// ���������� ��� ������ � ������������ �������� ����, ���� ������� ��
    /// ������� Base.FinishDate
    for task in fData.O['tasks'] do
    if (task.I['LocationID'] = GetLocationID) and  /// ���� ������ ��������� � ������� �������
       (StrToDate(task.S['DateStart']) < StrToDate(date)) then
    begin
        /// ���� ����� ���� ������ ������ ��������, ������������� ��������� ����
        if StrToDate(task.S['DateFinish']) <= StrToDate(date) then task.S['DateStart'] := date;
        /// ���� ����� ���� ������ ������ ��������, ���������� ��������� � �������� ���� (���������� ������ ����������)
        if StrToDate(task.S['DateFinish']) > StrToDate(date) then task.S['DateStart'] := task.S['DateFinish'];
    end;
end;

procedure TData.SetDateFinish(date: string);
/// ������������� �������� ����, ���� ��� ���� ���������
var
    task : ISuperObject;
begin
    if (GetDateBegin <> '') and (StrToDate(date) < StrToDate( GetDateBegin )) then exit;

    fData.S['Locations.'+IntToStr(GetLocationID)+'.FinishDate'] := date;

    if not Assigned(fData.O['tasks']) then exit;

    /// ���������� ��� ������ � ������������ �������� ����, ���� ������� ��
    /// ������� Base.FinishDate
    for task in fData.O['tasks'] do
    if (task.I['LocationID'] = GetLocationID) and  /// ���� ������ ��������� � ������� �������
       (StrToDate(task.S['DateFinish']) > StrToDate(date)) then
    begin
        if StrToDate(task.S['DateStart']) <= StrToDate(date) then task.S['DateFinish'] := date;
        if StrToDate(task.S['DateStart']) > StrToDate(date) then task.S['DateFinish'] := task.S['DateStart'];
    end;

end;

procedure TData.SetSelIndex(index: integer);
begin
    if not Assigned(fData) then exit;

    fData.I['Work.CurrTileIndex'] := index;
end;

initialization
    AppData := TData.Create;

finalization
    AppData.Free;

end.
