unit uAtlas;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts;

const

    /// ������ (������ layExample)
    /// �������������� ������������� � �������������� �������� �������� .
    /// ��������� ��� ����� ������������� � �������� ������, ����� ��������� ����� �������� � �����.
    /// ��� ������������� ������������ �������� ���� TAG
    WORK_TYPE           = 1;  /// �������� ����
    WORK_ICON           = 2;  /// ������ ����
    WORK_COLOR          = 3;  /// ���� ������
    WORK_COLOR_GRADIENT = 4;  /// ������ ���������
    WORK_COLOR_CONTOUR  = 5;  /// �������
    BRIGADA             = 6;  /// ����� ���������� �� ������

    /// � �������������� ��������� ���� TAG ����� ��������� ID ������ � ������� ��������.
    /// ������� �������� �� �����, �� �������� ������������ ������������, ����� ��� ������ ���������,
    /// ������������������� �� ��� ���������
    BUTTON_DAY_LESS       = -1;  /// ������ ���������� ������������ ������ �� ���� ����
    BUTTON_DAY_MORE       = -2;  /// ������ ���������� ������������ ������ �� ���� ����
    BUTTON_EDIT           = -3;  /// ������ ������ ������ �������������� ������
    BUTTON_DELETE         = -4;  /// ������ �������� ������
    BUTTON_ADD_PERSONE    = -5;  /// ������ ���������� ���������
    BUTTON_REMOVE_PERSONE = -6;  /// ������ �������� ���������
    BUTTON_COPY_NEXT      = -7;  /// ������ ����������� ������� ������� �� ��������� ����
    BUTTON_COPY_FULL      = -8;  /// ������ ����������� ������� ������� �� ��� ����������� ��� ������


    /// �������� ������� (������ layWorker)
    WORKER_KIND    = 1;   /// �������� ���� (�������/��������)
    WORKER_NAME    = 2;   /// ����� ��� ����������� �����
    WORKER_ISDEL   = 3;   /// ������-������� ��������
    WORKER_DELETE  = 4;   /// ������-������ ��������
    WORKER_RESTORE = 5;   /// ������-������ ��������������
    WORKER_BG      = 6;   /// ��� ��������


    /// ������� (������ layLocation)
    LOC_NAME = 1;   /// ������������ ������� � ��������� �����
    LOC_POS  = 2;   /// �������������� �������
    LOC_DEL  = 3;   /// ������ ��������
    LOC_BG   = 40;   /// ��� ��������
type
  TfAtlas = class(TForm)
    layExample: TLayout;
    Layout3: TLayout;
    FlowLayout1: TFlowLayout;
    Layout4: TLayout;
    AddPersone: TCircle;
    Image4: TImage;
    RemovePersone: TCircle;
    Image5: TImage;
    Rectangle1: TRectangle;
    Circle1: TCircle;
    WorkType: TImage;
    WorkName: TLabel;
    DayLess: TCircle;
    Image2: TImage;
    DayMore: TCircle;
    Image3: TImage;
    EditTask: TCircle;
    Image6: TImage;
    DeleteTask: TCircle;
    Image7: TImage;
    rGradient: TRectangle;
    rContainer: TRectangle;
    iWorker: TImage;
    Circle2: TCircle;
    Image1: TImage;
    iBrigadir: TImage;
    layWorker: TLayout;
    Image8: TImage;
    Label1: TLabel;
    Image9: TImage;
    Image10: TImage;
    Image11: TImage;
    Rectangle2: TRectangle;
    rLocation: TRectangle;
    Label2: TLabel;
    rLocationSel: TRectangle;
    Label3: TLabel;
    layLocation: TLayout;
    Rectangle3: TRectangle;
    Image12: TImage;
    Image14: TImage;
    Layout2: TLayout;
    Label4: TLabel;
    Label5: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fAtlas: TfAtlas;

implementation

{$R *.fmx}

uses uInterface;

end.
