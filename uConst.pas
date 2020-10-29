unit uConst;

interface

uses
    superobject;

type
    TEvent = procedure of object;
//    TPEvent = procedure(data: ISuperObject = nil) of object;
    TFEvent = function: ISuperObject of object;
    TFFEvent = function(data: ISuperObject = nil): ISuperObject of object;

    TProc = procedure(val: variant) of object;

    TSpravAnsverEvent = procedure(name: string; data: ISuperObject) of object;
    TSpravRequestEvent = procedure(callback: TSpravAnsverEvent; name: string) of object;

    TMessActivateEvent = procedure(text: string) of object;

const
    ANIMATION_SPEED        = 0.2; /// скорость всех анимаций
    TASK_LAYER_MAX_HEIGHT  = 30;

    SPRAV_SHOW_LINES_COUNT = 100; /// для больших справочников. сколько записей отображать единовременно
    SPRAV_LETTERS_COUNT    = 3;   /// количество букв с которого начинается фильтрация данных в справочнике

    TASK_MAX_ID = 10000;

    INI_FILE_NAME = 'data.ini';
    SETTINGS_FILE_NAME = 'settings.dat';
    DATA_DIR = 'data\';

    /// имена режимов
    MODE_NONE       = 'modeNone';
    MODE_INFO       = 'modeInfo';
    MODE_TASK       = 'modeTask';
    MODE_SETTINGS   = 'modeSettings';
    MODE_WORKERS    = 'modeWorkers';
    MODE_LOCATION   = 'modeLocation';
    MODE_NEWMISSION = 'modeNewMission';

    /// имя формы
    FORM_SPRAV = 'sprav_form';
    FORM_MAIN  = 'main_form';
    FORM_MESSAGE = 'mess_form';
    FORM_QUESTION = 'mess_question';

    /// синонимы справочников
    SPRAV_WORKTYPES      = 'WorkTypes';
    SPRAV_IDLEACT        = 'IdleActs';
    SPRAV_AUTOS          = 'Autos';
    SPRAV_OFFERSSERVICES = 'OffersServices';
    SPRAV_PAYTYPES       = 'PayTypes';
    SPRAV_DRIVERS        = 'Drivers';
    SPRAV_OFFERSCLAIMS   = 'OffersClaims';
    SPRAV_NOMENKL        = 'Nomenkl';
    SPRAV_INKOMPLINSTALL = 'IncomplInstall';
    SPRAV_ORGANIZATIONS  = 'Organizations';
    SPRAV_WORKERS        = 'Workers';
    SPRAV_OBJECTS        = 'Objects';
    SPRAV_PLACES         = 'Places';


    TASK_SHABLON = '{'+
        'ID:              "",'+          /// уникальный признак
        'LocationID:       0,'+          /// ссылка на элемент справочника локаций Sprav.Locations
        'Layer:            0,'+          /// значение для формирования интерфейса.
                                         /// если несколько задач пересекаются в один день, то каждая отрисовывается на своем layer
        'DateStart:       "",'+          /// дата начала задачи
        'DateFinish:      "",'+          /// дата завершения задачи
        'WorkType:        "",'+          /// вид работ. справочник WorkTypes
        'WorkTypeID:       0,'+          /// вид работ. справочник WorkTypes
        'Nomenkl:         "",'+          /// номенклатурная группа. справочник Nomenkl для WorkTypes.Reason <> 'Основание не требуется'
        'NomenklID:        0,'+          /// номенклатурная группа. справочник Nomenkl для WorkTypes.Reason <> 'Основание не требуется'
        'ReasonType:      "",'+          /// тип основания. WorkTypes.Reason
        'ReasonSprav:     "",'+          /// имя справочника, из которого брать данные. берется из WorkTypes.Sprav при вида работ
        'Reasons:['+                     /// массив прикрученных оснований
//           '{name:     "reason1",'+    /// данные справочника имя которого содержится в WorkTypes.Sprav
//            'id:    0},'+              /// данные справочника имя которого содержится в WorkTypes.Sprav
//           '{name:     "reason2",'+    /// данные справочника имя которого содержится в WorkTypes.Sprav
//            'id:    0},'+              /// данные справочника имя которого содержится в WorkTypes.Sprav
        '],'+

        'AutoUsed:     false,'+     /// признак использования автомобиля
        'Organization:    "",'+    /// оргагнизация. справочник Organizations
        'OrganizationID:   0,'+    /// оргагнизация. справочник Organizations
        'Driver:          "",'+    /// водитель. справочник Drivers
        'DriverID:         0,'+    /// водитель. справочник Drivers
        'AutoNumber:      "",'+    /// госномер. справочник Autos
        'AutoNumberID:     0,'+    /// госномер. справочник Autos
        'IdleAct:         "",'+    /// акт простоя. справочник IdleActs
        'IdleActID:        0,'+    /// акт простоя. справочник IdleActs

        'LivingUsed:   false,'+    /// признак использования проживания
        'PayType:         "",'+    /// тип оплаты. справочник PayTypes
        'Summa:           "",'+    /// сумма оплаты без НДС

        'Brigada:{'+                /// работник(-и) назначеные на задачу на каждый день
                                    /// "346":{"101":1,"102":1,"103":0}, состав бригады на каждый день,
                                    /// где ключ - id работника, ключ поля = год * 10000 + месяц * 100 + номер дня,
                                    /// а значение: 0 - не присутствует, 1 - присутствует
        '},'+
    '}';

    LOCATION_SHABLON = '{'+
        'id: 0,'+
        'ObjectPlace: "",'+
        'ZavNum: "",'+
        'ObjectPlaceID: 0,'+
        'ObjectName: "",'+
        'StartDate: "",'+
        'FinishDate: "",'+
        'LyerCount: 0,'+
        'Deleted: false,'+
    '}';

    WORKER_SHABLON = '{'+
        '"datestart": "", '+
        '"id": 0, '+
        '"name": "", '+
        '"datefinish": "" '+
    '}';

    BASE_SHABLON = '{'+
      'BrigadaID: 0,'+
      'BrigaderID: 0,'+
      'BrigadaName: "",'+
      'Brigader: "",'+
      'NextLocID: 1,'+
    '}';

implementation

end.

////////////////////////////////////////////////////////////////////////////////
///    СТРУКТУРА РАБОЧЕГО ФАЙЛА
////////////////////////////////////////////////////////////////////////////////
{
 "Work": {
  "FirstDay": 8,
  "EndYear": 0,
  "EndDay": 0,
  "CurrDate": "01.09.2020",
  "EndMonth": 0,
  "FirstMonth": 9,
  "CurrFrameDate": "31.08.2020",
  "CurrMonthName": "Сентябрь",
  "FirstYear": 2020,
  "LayerCount": 0
  "LocationID" : 0,
 },
"Base": {
  "BrigadaID": 121,
  "BrigaderID": 375,
  "BrigadaName": "Бузулукский П.А. / УСК Новый уренгой",
  "Brigader": "Бузулукский П.А.",
  "NextLocID": 1,
 },
 "tasks":{
    see TASK_SHABLON
 },
  "Locations": {
     "0":{
        id: 0,
        ObjectPlace: "Ямало-Ненецкий автономный округ, г.Новый Уренгой ",
        ZavNum: "3302553",
        ObjectPlaceID: -532,
        ObjectName: "33 02 085/16_Поставка УПТГ для \"Тургменгаз\"_"
        LayerCount: 0;
        Deleted: false,'+
     },
  },
  "Workers": [
   {
    "datestart": "19.05.2020",
    "id": 375,
    "name": "Бузулукский П.А.",
    "datefinish": ""
   },{
    "datestart": "11.05.2020",
    "id": 4312,
    "name": "Антонов Е.О.",
    "datefinish": "19.05.2020"
   },{
    "datestart": "20.05.2020",
    "id": 4312,
    "name": "Антонов Е.О.",
    "datefinish": "31.05.2020"
   }],





 "Sprav": {
  "IdleActs": [
   {
    "id": 8,
    "name": "01/08/19 от 2019-08-01 \"Режим работы 4 часа\""
   },...],
  "Objects": [  /// устанаыливаемые объекты (заводские номера)
   {
    "id": 0,
    "name": "Блок распределительный КПР-К45С"
   },...],
  "Places": [  /// географические места работ
   {
    "id": 0,
    "name": "г.Тюмень""
   },...],
  "Autos": [
   {
    "id": 22,
    "name": "C204MP72 [[Reno Duster]]"
   },...],
  "OffersServices": [
   {
    "id": 861384,
    "name": ""
   },...],
  "PayTypes": [
   "Наличный расчёт","Безналичный расчёт","За счёт заказчика","Другое"],
  "Drivers": [
   {
    "id": 100,
    "name": "Аминов Илдус Ратифович"
   },...],
  "WorkTypes": [
   {
    "id": 0,
    "Reason": "Предложение о включении претензии в план",
    "AccExpens": 20,
    "sprav": "OffersClaims",
    "name": "УЗ - устранение замечаний",
    "smallname": "УЗ"
   },...],
  "OffersClaims": [
   {
    "id": 1891626,
    "name": "0042/18 от 2018-01-22 касательно выявленных замечаний"
   },...],
  "Nomenkl": [
   {
    "id": 8315,
    "name": " (ст.зав.№ 769) БКНС ТНГиДХ Укрытия для водонагнетательных скважин"
   },...],
  "IncomplInstall": [
   {
    "id": 1272829,
    "name": "Акт незавершенного монтажа № нормо-часа на каждый номер. от 31.03.2016  (Акт незавершенного монтажа по с.з на 5503-5710)"
   },...],
  "Organizations": [
   {
    "id": 1002933,
    "name": " Институт транспорта нефти ПАО"
   },...]
 }
}

