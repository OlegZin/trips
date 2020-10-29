unit uData;

interface

uses
    superobject, System.UITypes, FMX.Graphics, System.Types,
    SysUtils, DateUtils, Math, StrUtils, uConst;

type
    TData = class
      private
        fData: ISuperObject;     /// рабочие данные (задачи, справочники)
        fSettings: ISuperObject; /// настройки отображения (цвет по типам задач, иконки)
        fFilename : string;      /// текущий открытый рабочий файл
        fSpravFilename : string; /// текущий открытый файл справочников

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
        function GetTaskData(id: string): ISuperObject;  /// получаем данные задачи
        procedure SetTask(data: ISuperObject);           /// сздаем/обновляем задачу (data содержит поле ID)
        procedure UpdateTaskLayers;                      /// пересчитываем параметр layer всех задач для
                                                         /// корректного отображения пересекающихся задач в интерфейсе

        function GetSpravData(name: string): ISuperObject;  /// получение данных справочника с указанным именем

        /// индекс тайла - смещение в днях от стартовой даты текущего отрисовываемого фрейма
        ///    фрейм - сетка дней, отображаемая в интерфейсе. если текущий отображаемый месяц
        ///    начинается с понедельника, то начало фрейма будет совпадать с первым днем месяца.
        ///    в ином случае, начало фрейма будет сдвинуто на предидущий месяц (к последнему понедельнику)
        procedure SetSelIndex(index: integer); /// устанавливаем индекс текущего выделенного тайла
        function GetSelIndex: integer;         /// получаем индекс текущего выделенного тайла

        function GetMaxLayers: Integer;

        function GetSettingsData: ISuperObject;
        procedure SaveSettings(data: ISuperObject);
        function GetKindColor(id: integer): TColor;
        function GetKindIcon(id: integer): TBitmap;

        /// набор методов реализации управления задачей
        function TaskDayLess(id: integer): boolean;  /// уменьшает длительность задачи на 1 день, но не короче 1 дня
        function TaskDayMore(id: integer): boolean;  /// увеличивает длительность задачи на 1 день
        function TaskDelete(id: integer): boolean;  /// увеличивает длительность задачи на 1 день

        function AddWorker(taskID: integer; data: ISuperObject): boolean;
                                                    /// добавляем работника на указанную задачу на текущий день
        function RemoveWorker(taskID, workerID: integer): boolean;
                                                    /// удаляем работника с указанной задачи на текущий день
        function TaskCopyNext(taskID: integer): boolean; // копируем состав бригады с текущего дня на следующий
        function TaskCopyFull(taskID: integer): boolean; // копируем состав бригады с текущего дня до конца задачи

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
///    метод получает данные дня относительно даты Work.CurrFrameDate.
///    где index = 1 - совпадает с Work.CurrFrameDate, 2 = Work.CurrFrameDate+1 день и т.д.
var
    date: TDate;
    datestr, strBrigada, dayID: string;
    task, worker, brigada: ISuperObject;
begin
    result := nil;

    /// если не выбрана дата начала фрейма - ничего не возвращаем
    if not Assigned(fData) or not Assigned(fData.O['Work.CurrFrameDate']) or (fData.S['Work.CurrFrameDate'] = '') then exit;
    /// если не выбрана локация - возвращать нечего
    if not isLocationSelected then exit;

    if index = -1 then index := GetSelIndex;

    /// получаем по индексу дату выделенного тайла
    date := IncDay( StrToDate(fData.S['Work.CurrFrameDate']), index-1 );
    datestr := FormatDateTime( 'dd.mm.yyyy', date );

    /// не будем возвращать данные, если дата выходит за пределы начальной и конечной даты
    if (GetDateFinish <> '') and ( date > StrToDate(GetDateFinish)) then exit;
    if (GetDateBegin <> '') and ( date < StrToDate(GetDateBegin)) then exit;

    /// не будем возвращать данные, если даты не заданы
    if (GetDateFinish = '') and (GetDateBegin = '') then exit;

    /// формируем
    result := SO();

    result.I['day'] := DayOf( date );  /// номер дня
    result.S['month'] := FormatDateTime( 'mmmm', date );  /// название месяца
    dayID := IntTostr(YearOf( date ) * 10000 + MonthOf( date ) * 100 + DayOf( date ));

    /// перебираем задачи и формируем массив с данными задач, попадающих в этот день
    If Assigned(fData.O['tasks']) then
    for task in fData.O['tasks'] do

    /// если текущий день попадает во временные рамки задачи
    if (StrToDate(task.S['DateStart']) <= date) and (StrToDate(task.S['DateFinish']) >= date) and
    /// и задача относится к текущему выбранному объекту
      (task.I['LocationID'] = GetLocationID)
    then
    begin
        brigada := SA([]);

        /// перебираем всех работников и проверяем, назначены ли они на задачу на этот день
        if assigned( fData.O['Workers'] ) then
        for worker in fData.O['Workers'] do
        if assigned(task.O['Brigada.'+worker.S['id']+'.'+dayID]) and
            (task.I['Brigada.'+worker.S['id']+'.'+dayID] = 1)
        then
            brigada.AsArray.Add(SO('{name:"'+worker.S['name']+'",id:'+worker.S['id']+'}'));


        /// добавляем элемент в массив зедач
        result['tasks[]'] := SO(
        '{'+
           'id:' + task.S['ID'] + ','+  // является ли этот день днем начала задачи
           'first:' + ifthen( StrToDate(task.S['DateStart']) = date, 'true', 'false' ) + ','+  // является ли этот день днем начала задачи
           'last:' + ifthen( StrToDate(task.S['DateFinish']) = date, 'true', 'false' ) + ','+  // является ли этот день днем окончания задачи
           'layer:' + task.S['layer'] + ','+              // на каком слое отображать задачу
           'WorkTypeID:' + task.S['WorkTypeID'] + ','+    // тип задачи
           'WorkType:' + task.S['WorkType'] + ','+        // имя задачи
           'brigada:' + brigada.AsJSon + ','+             // состав бригады на этот день
           'workCount:' + IntToStr(brigada.AsArray.Length) + ','+             // состав бригады на этот день
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
    /// если присутствуют настройки для данного типа
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
    /// если присутствуют настройки для данного типа
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

    /// проверяем наличие удаленных элементов
    for loc in data do
    if loc.B['Deleted'] then  /// если локация удалена
    begin
        /// удалим и ее задачи, если есть
        if Assigned(fData.O['tasks']) then
        for task in fData.O['tasks'] do
        if task.I['LocationID'] = loc.I['id'] then
        fData.Delete('tasks.'+task.S['ID']);

        /// и саму локацию помечаем на удаление.
        /// если грохнуть ее сейчас и она была последней, то перебор "for loc in data do"
        /// сломается исключением
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
/// data - данные работника, элемент из справочника Sprav.Workers
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
/// data - данные работника, элемент из справочника Sprav.Workers
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

    /// дата не установлена
    if GetDateFinish = '' then
    begin
        result := true;
        exit;
    end;

    /// текущий месяц ниже стартовой даты
    result := MonthOf(StrToDate(fData.S['Work.CurrDate'])) < MonthOf(StrToDate(GetDateFinish));
end;

function TData.AllowPrev: boolean;
begin
    result := false;

    if not Assigned( fData ) or not Assigned( fData.O['Work.CurrDate'] ) or (fData.S['Work.CurrDate'] = '') or (GetDateBegin = '') then exit;

    /// текущий месяц дальше стартовой даты
    result := StrToDate( fData.S['Work.CurrDate'] ) > StrToDate( GetDateBegin );
end;

procedure TData.SetTask(data: ISuperObject);
/// добавление/обновление задачи
begin
    /// если это новая задача
    if not Assigned(fData.O['tasks.'+data.S['ID']]) then
    begin
        /// инициализируем временные рамки задачи текущим выбранным днем
        data.S['DateStart'] := DateToStr( GetTileDate );
        data.S['DateFinish'] := DateToStr( GetTileDate );
        data.I['LocationID'] := GetLocationID; // привязываем к текущей выбранной локации
    end;

    if not Assigned(fData.O['tasks'])
    then fData.O['tasks'] := SO('{}');

    fData.O['tasks.'+data.S['ID']] := data;
end;

procedure TData.SetWorkers(data: ISuperObject);
var
    pers, task: ISuperobject;
begin
    /// заливаем обновленные данные списка бригады
    fData.O['Workers'] := data.Clone;

    /// проверяем, если есть удаленные работники,
    /// снимаем их со всех задач
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

    /// перебираем всех работников
    for worker in fData.O['Workers'] do
    /// если на данного работника на текущий день есть запись присутствия
    if Assigned( fData.O['tasks.'+IntToStr(taskID)+'.Brigada.'+worker.S['id']+'.'+dayID] ) then
    begin
        // пишем присутствие этого работника на следующий день
        fData.O['tasks.'+IntToStr(taskID)+'.Brigada.'+worker.S['id']+'.'+nextdayID] :=
            fData.O['tasks.'+IntToStr(taskID)+'.Brigada.'+worker.S['id']+'.'+dayID].Clone;
        result := true;
    end;
end;

function TData.TaskDayLess(id: integer): boolean;
/// уменьшаем конечную дату задачи на 1 день, если он больше начальной даты
var
    DateStart, DateFinish: TDate;
begin
    result := false;

    /// существует ли такая задача?
    if not Assigned( fData.O['tasks.'+IntToStr(id)] ) then exit;

    DateStart := StrToDate( fData.S['tasks.'+IntToStr(id)+'.DateStart'] );
    DateFinish := StrToDate( fData.S['tasks.'+IntToStr(id)+'.DateFinish'] );

    /// уменьшать больше нельзя
    if DateStart = DateFinish then exit;

    fData.S['tasks.'+IntToStr(id)+'.DateFinish'] := DateToStr( IncDay( DateFinish, -1 ) );

    UpdateTaskLayers;

    result := true;
end;

function TData.TaskDayMore(id: integer): boolean;
/// уменьшаем конечную дату задачи на 1 день, если он больше начальной даты
var
    DateStart, DateFinish: TDate;
    setTotal: boolean;
begin
    result := false;

    /// существует ли такая задача?
    if not Assigned( fData.O['tasks.'+IntToStr(id)] ) then exit;

    DateStart := StrToDate( fData.S['tasks.'+IntToStr(id)+'.DateStart'] );
    DateFinish := StrToDate( fData.S['tasks.'+IntToStr(id)+'.DateFinish'] );

    /// увеличивать больше конечной даты командировки нельзя
    if Assigned(fData.O['Base.FinishDate']) and (DateFinish >= StrToDate(fData.S['Base.FinishDate'])) then exit;

    fData.S['tasks.'+IntToStr(id)+'.DateFinish'] := DateToStr( IncDay( DateFinish, 1 ) );

    UpdateTaskLayers;

    result := true;
end;

function TData.TaskDelete(id: integer): boolean;
/// удаляем задачу с указанным id
begin
    result := true;
    fData.Delete('tasks.'+IntToStr(id));
    UpdateTaskLayers;
end;

procedure TData.UpdateTaskLayers;
/// метод расстановки задач по "слоям", чтобы они красиво отрисовывались в
/// интерфейсе. задачи, пересекающиеся на одну дату должны иметь разные значения layer и привязки к локации
///    алгоритм:
///    - перебираем все задачи и обнуляем значение layer
///    - перебираем все задачи
///      - для текущей(Т) ищем остальные задачи попадающие в дату ее начала
///      - собираем все значения layer этих задач (если установлены - значит уже обработаны и эти layer занимать нельзя)
///      - выбираем наименьшее оставшееся значение ближе к 0 и присваиваем задаче T
var
    maxLayer, freeLayer: integer;
    mainTask, task, layers: ISuperObject;
    item: TSuperAvlEntry;
begin

    if not Assigned( fData['tasks'] ) then exit; // нет задач

    maxLayer := 0;

    for task in fData['tasks'] do          // сбрасываем данные по слоям
        if task.I['LocationID'] = GetLocationID
        then task.I['layer'] := 0;

    fData.I['Locations.'+IntToStr(GetLocationID)+'.LayerCount'] := 0;

    for mainTask in fData['tasks'] do      // для каждой задачи
    if mainTask.I['LocationID'] = GetLocationID then
    begin

        // инициализируем массив признаков занятых слоев
        layers := SO('{"1":false,"2":false,"3":false,"4":false,"5":false,"6":false,"7":false,"8":false,"9":false}');
        freeLayer := 10;

        for task in fData['tasks'] do      // перебираем все остальные
        if task.I['LocationID'] = GetLocationID then
        begin

            if (task = mainTask) then Continue;
                                           // пересекающиеся с ней по датам
            if
             (/// пересечение по начальной дате (есть в обеих задачах)
              ((StrToDate(task.S['DateStart']) >= StrToDate(mainTask.S['DateStart'])) and
               (StrToDate(task.S['DateStart']) <= StrToDate(mainTask.S['DateFinish']))) or
              /// пересечение по конечной дате (есть в обеих задачах)
              ((StrToDate(task.S['DateFinish']) >= StrToDate(mainTask.S['DateStart'])) and
               (StrToDate(task.S['DateFinish']) <= StrToDate(mainTask.S['DateFinish']))) or
              /// пересечение с поглащением (проверяемая задача длиннее в обе стороны)
              ((StrToDate(task.S['DateStart']) <= StrToDate(mainTask.S['DateStart'])) and
               (StrToDate(task.S['DateFinish']) >= StrToDate(mainTask.S['DateFinish'])))
              ) then
                                           // и отмечаем номер занятого слоя
            if   task.I['layer'] > 0
            then layers.B[ task.S['layer'] ] := true;
        end;

        /// перебираем признаки слоев и ищем минимальный (для текущей задачи) и максимальный (для интерфейсной переменной)
        for item in layers.AsObject do
        begin
            /// свободный слой, ищем минимальный из свободных
            if not item.Value.AsBoolean then freeLayer := Min( freeLayer, StrToInt(item.Name));
            /// занятый слой, ищем максимальный из занятых
            if item.Value.AsBoolean then maxLayer := Max( maxLayer, StrToInt(item.Name));
        end;

        /// пишем в глобальную переменную маскимальный найденный занятый слой.
        /// в дальнейшем это значение будет использоваться при построении интерфейса
        /// для вычисления высоты одного слоя в ячейке дня
        fData.I['Locations.'+IntToStr(GetLocationID)+'.LayerCount'] := max( fData.I['Locations.'+IntToStr(GetLocationID)+'.LayerCount'], Max( maxLayer, freeLayer));

        /// задаем найденый слой текущей задаче и берем следующую...
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
/// метод отдающий данные окну настроек
var
    item: ISuperObject;
begin

    /// перебираем справочник типов работ и пихаем в данные настроек отсутствующие элементы
    if Assigned(fData.O['Sprav.WorkTypes']) then
    for item in fData.O['Sprav.WorkTypes'] do
    begin

        if not Assigned(fSettings.O[ item.S['id'] ]) then
        fSettings[ item.S['id'] ] := SO('{id: '+item.S['id']+',name:"'+item.S['name']+'", color: '+IntToStr(TAlphaColorRec.Lightskyblue)+', icon: 0}');

    end;

    result := fSettings;

end;
function TData.SaveData(filename : string): boolean;
/// к рабочим данным будем относить всю накопленную информацию, кроме раздела справочников
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
/// сохраняем текущие настройки отображения
begin
    data.SaveTo( ExtractFilePath(paramstr(0)) + SETTINGS_FILE_NAME, false);
end;




function TData.GetSpravData(name: string): ISuperObject;
/// тонкость в том, что некоторые справочники могут быть динамическими
///    и находиться вне раздела Sprav.
///    например, Workers. Это рабочие данные.
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
    else result := fData.O['Workers'].Clone;  /// берем справочник бригады

    /// указываем бригадира
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

    /// загрузка рабочих данных
    try
        /// сохраняем справочники если есть
        if assigned(fData) and assigned(fData.O['Sprav']) then part := fData.O['Sprav'].clone;

        fData := TSuperObject.ParseFile( filename, false);
        fFileName := filename;

        /// восстанавливаем справочники
        if assigned(part) then fData.O['Sprav'] := part.clone;
    except
    end;

    result := Assigned(fData);

end;

procedure TData.LoadSettings;
begin
    /// загрузка данных настроек,если есть
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

    /// загрузка рабочих данных
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

    /// данные стартовой даты
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

    /// данные текущего выбранного месяца
    SetCurrDate( StartOfTheMonth(date) );

    /// данные конечной даты
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
/// пересоздаем данные командировки, но сохраняем загруженные в данный момент справочники
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
    /// данные текущей даты (месяца)
    fData.S['Work.CurrDate']       := DateToStr(date);
    fData.S['Work.CurrMonthName']  := FormatDateTime('mmmm', date);

    /// данная дата отмечает начало "фрейма" - ближайший понедельник до
    /// даты начала текущего месяца, либо сама дата начала месяца, если он
    /// с понедельника.
    /// используется в механизме заполнения фрейма данными последних днйе
    /// предыдущего месяца.
    fData.S['Work.CurrFrameDate']  := FormatDateTime('dd.mm.yyyy',IncDay(StartOfTheMonth(date), - DayOfTheWeek( StartOfTheMonth(date)-1 )));
end;

procedure TData.SetDateBegin(date: string);
/// устанавливаем конечную дату, если она выше стартовой
var
    task : ISuperObject;
begin
    if  (GetDateFinish <> '') and (StrToDate(date) > StrToDate( GetDateFinish )) then exit;

    fData.S['Locations.'+IntToStr(GetLocationID)+'.StartDate'] := date;

    if not Assigned(fData.O['tasks']) then exit;

    /// перебираем все задачи и корректируем конечные даты, если выходят за
    /// пределы Base.FinishDate
    for task in fData.O['tasks'] do
    if (task.I['LocationID'] = GetLocationID) and  /// если задача относится к текущей локации
       (StrToDate(task.S['DateStart']) < StrToDate(date)) then
    begin
        /// если новая дата начала меньше конечной, устанавливаем указанную дату
        if StrToDate(task.S['DateFinish']) <= StrToDate(date) then task.S['DateStart'] := date;
        /// если новая дата начала больше конечной, уравниваем стартовую и конечную даты (становится задача однодневка)
        if StrToDate(task.S['DateFinish']) > StrToDate(date) then task.S['DateStart'] := task.S['DateFinish'];
    end;
end;

procedure TData.SetDateFinish(date: string);
/// устанавливаем конечную дату, если она выше стартовой
var
    task : ISuperObject;
begin
    if (GetDateBegin <> '') and (StrToDate(date) < StrToDate( GetDateBegin )) then exit;

    fData.S['Locations.'+IntToStr(GetLocationID)+'.FinishDate'] := date;

    if not Assigned(fData.O['tasks']) then exit;

    /// перебираем все задачи и корректируем конечные даты, если выходят за
    /// пределы Base.FinishDate
    for task in fData.O['tasks'] do
    if (task.I['LocationID'] = GetLocationID) and  /// если задача относится к текущей локации
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
