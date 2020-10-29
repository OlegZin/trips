unit uAtlas;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts;

const

    /// ЗАДАЧА (шаблон layExample)
    /// идентификаторы информативных и функциональных объектов болванки .
    /// поскольку она будет клонироваться в процессе работы, имена компонент будут обнулены в клоне.
    /// для идентификации используются значения поля TAG
    WORK_TYPE           = 1;  /// название типа
    WORK_ICON           = 2;  /// иконка типа
    WORK_COLOR          = 3;  /// цвет плашки
    WORK_COLOR_GRADIENT = 4;  /// объект градиента
    WORK_COLOR_CONTOUR  = 5;  /// обводка
    BRIGADA             = 6;  /// набор работников на задаче

    /// у функциональных элементов поле TAG будет содержать ID задачи с которой работает.
    /// особого значения не имеет, но признаки функционалов отицательные, чтобы при случае проверить,
    /// проинициализированы ли они нормально
    BUTTON_DAY_LESS       = -1;  /// кнопка уменьшения длительности задачи на один день
    BUTTON_DAY_MORE       = -2;  /// кнопка увеличения длительности задачи на один день
    BUTTON_EDIT           = -3;  /// кнопка вызова режима редактирования задачи
    BUTTON_DELETE         = -4;  /// кнопка удаления задачи
    BUTTON_ADD_PERSONE    = -5;  /// кнопка добавления работника
    BUTTON_REMOVE_PERSONE = -6;  /// кнопка удаления работника
    BUTTON_COPY_NEXT      = -7;  /// кнопка копирования состава бригады на следующий день
    BUTTON_COPY_FULL      = -8;  /// кнопка копирования состава бригады на все последующие дни задачи


    /// УЧАСТНИК БРИГАДЫ (шаблон layWorker)
    WORKER_KIND    = 1;   /// картинка типа (обычный/бригадир)
    WORKER_NAME    = 2;   /// лейбл для отображения имени
    WORKER_ISDEL   = 3;   /// иконка-признак удаления
    WORKER_DELETE  = 4;   /// иконка-кнопка удаления
    WORKER_RESTORE = 5;   /// иконка-кнопка восстановления
    WORKER_BG      = 6;   /// фон элемента


    /// ЛОКАЦИЯ (шаблон layLocation)
    LOC_NAME = 1;   /// наименование объекта и заводской номер
    LOC_POS  = 2;   /// местоположение объекта
    LOC_DEL  = 3;   /// кнопка удаления
    LOC_BG   = 40;   /// фон элемента
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
