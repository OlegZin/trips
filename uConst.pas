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
    ANIMATION_SPEED        = 0.2; /// �������� ���� ��������
    TASK_LAYER_MAX_HEIGHT  = 30;

    SPRAV_SHOW_LINES_COUNT = 100; /// ��� ������� ������������. ������� ������� ���������� �������������
    SPRAV_LETTERS_COUNT    = 3;   /// ���������� ���� � �������� ���������� ���������� ������ � �����������

    TASK_MAX_ID = 10000;

    INI_FILE_NAME = 'data.ini';
    SETTINGS_FILE_NAME = 'settings.dat';
    DATA_DIR = 'data\';

    /// ����� �������
    MODE_NONE       = 'modeNone';
    MODE_INFO       = 'modeInfo';
    MODE_TASK       = 'modeTask';
    MODE_SETTINGS   = 'modeSettings';
    MODE_WORKERS    = 'modeWorkers';
    MODE_LOCATION   = 'modeLocation';
    MODE_NEWMISSION = 'modeNewMission';

    /// ��� �����
    FORM_SPRAV = 'sprav_form';
    FORM_MAIN  = 'main_form';
    FORM_MESSAGE = 'mess_form';
    FORM_QUESTION = 'mess_question';

    /// �������� ������������
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
        'ID:              "",'+          /// ���������� �������
        'LocationID:       0,'+          /// ������ �� ������� ����������� ������� Sprav.Locations
        'Layer:            0,'+          /// �������� ��� ������������ ����������.
                                         /// ���� ��������� ����� ������������ � ���� ����, �� ������ �������������� �� ����� layer
        'DateStart:       "",'+          /// ���� ������ ������
        'DateFinish:      "",'+          /// ���� ���������� ������
        'WorkType:        "",'+          /// ��� �����. ���������� WorkTypes
        'WorkTypeID:       0,'+          /// ��� �����. ���������� WorkTypes
        'Nomenkl:         "",'+          /// �������������� ������. ���������� Nomenkl ��� WorkTypes.Reason <> '��������� �� ���������'
        'NomenklID:        0,'+          /// �������������� ������. ���������� Nomenkl ��� WorkTypes.Reason <> '��������� �� ���������'
        'ReasonType:      "",'+          /// ��� ���������. WorkTypes.Reason
        'ReasonSprav:     "",'+          /// ��� �����������, �� �������� ����� ������. ������� �� WorkTypes.Sprav ��� ���� �����
        'Reasons:['+                     /// ������ ������������ ���������
//           '{name:     "reason1",'+    /// ������ ����������� ��� �������� ���������� � WorkTypes.Sprav
//            'id:    0},'+              /// ������ ����������� ��� �������� ���������� � WorkTypes.Sprav
//           '{name:     "reason2",'+    /// ������ ����������� ��� �������� ���������� � WorkTypes.Sprav
//            'id:    0},'+              /// ������ ����������� ��� �������� ���������� � WorkTypes.Sprav
        '],'+

        'AutoUsed:     false,'+     /// ������� ������������� ����������
        'Organization:    "",'+    /// ������������. ���������� Organizations
        'OrganizationID:   0,'+    /// ������������. ���������� Organizations
        'Driver:          "",'+    /// ��������. ���������� Drivers
        'DriverID:         0,'+    /// ��������. ���������� Drivers
        'AutoNumber:      "",'+    /// ��������. ���������� Autos
        'AutoNumberID:     0,'+    /// ��������. ���������� Autos
        'IdleAct:         "",'+    /// ��� �������. ���������� IdleActs
        'IdleActID:        0,'+    /// ��� �������. ���������� IdleActs

        'LivingUsed:   false,'+    /// ������� ������������� ����������
        'PayType:         "",'+    /// ��� ������. ���������� PayTypes
        'Summa:           "",'+    /// ����� ������ ��� ���

        'Brigada:{'+                /// ��������(-�) ���������� �� ������ �� ������ ����
                                    /// "346":{"101":1,"102":1,"103":0}, ������ ������� �� ������ ����,
                                    /// ��� ���� - id ���������, ���� ���� = ��� * 10000 + ����� * 100 + ����� ���,
                                    /// � ��������: 0 - �� ������������, 1 - ������������
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
///    ��������� �������� �����
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
  "CurrMonthName": "��������",
  "FirstYear": 2020,
  "LayerCount": 0
  "LocationID" : 0,
 },
"Base": {
  "BrigadaID": 121,
  "BrigaderID": 375,
  "BrigadaName": "����������� �.�. / ��� ����� �������",
  "Brigader": "����������� �.�.",
  "NextLocID": 1,
 },
 "tasks":{
    see TASK_SHABLON
 },
  "Locations": {
     "0":{
        id: 0,
        ObjectPlace: "�����-�������� ���������� �����, �.����� ������� ",
        ZavNum: "3302553",
        ObjectPlaceID: -532,
        ObjectName: "33 02 085/16_�������� ���� ��� \"����������\"_"
        LayerCount: 0;
        Deleted: false,'+
     },
  },
  "Workers": [
   {
    "datestart": "19.05.2020",
    "id": 375,
    "name": "����������� �.�.",
    "datefinish": ""
   },{
    "datestart": "11.05.2020",
    "id": 4312,
    "name": "������� �.�.",
    "datefinish": "19.05.2020"
   },{
    "datestart": "20.05.2020",
    "id": 4312,
    "name": "������� �.�.",
    "datefinish": "31.05.2020"
   }],





 "Sprav": {
  "IdleActs": [
   {
    "id": 8,
    "name": "01/08/19 �� 2019-08-01 \"����� ������ 4 ����\""
   },...],
  "Objects": [  /// ��������������� ������� (��������� ������)
   {
    "id": 0,
    "name": "���� ����������������� ���-�45�"
   },...],
  "Places": [  /// �������������� ����� �����
   {
    "id": 0,
    "name": "�.������""
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
   "�������� ������","����������� ������","�� ���� ���������","������"],
  "Drivers": [
   {
    "id": 100,
    "name": "������ ����� ���������"
   },...],
  "WorkTypes": [
   {
    "id": 0,
    "Reason": "����������� � ��������� ��������� � ����",
    "AccExpens": 20,
    "sprav": "OffersClaims",
    "name": "�� - ���������� ���������",
    "smallname": "��"
   },...],
  "OffersClaims": [
   {
    "id": 1891626,
    "name": "0042/18 �� 2018-01-22 ���������� ���������� ���������"
   },...],
  "Nomenkl": [
   {
    "id": 8315,
    "name": " (��.���.� 769) ���� ������ ������� ��� ������������������ �������"
   },...],
  "IncomplInstall": [
   {
    "id": 1272829,
    "name": "��� �������������� ������� � �����-���� �� ������ �����. �� 31.03.2016  (��� �������������� ������� �� �.� �� 5503-5710)"
   },...],
  "Organizations": [
   {
    "id": 1002933,
    "name": " �������� ���������� ����� ���"
   },...]
 }
}

