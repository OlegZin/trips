unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Objects,
  FMX.DateTimeCtrls;

type
  TfMain = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    tileDay11: TRectangle;
    Circle1: TCircle;
    Label8: TLabel;
    tileDay12: TRectangle;
    Circle2: TCircle;
    Label9: TLabel;
    tileDay13: TRectangle;
    Circle3: TCircle;
    Label10: TLabel;
    tileDay14: TRectangle;
    Circle4: TCircle;
    Label11: TLabel;
    tileDay15: TRectangle;
    Circle5: TCircle;
    Label12: TLabel;
    tileDay16: TRectangle;
    Circle6: TCircle;
    Label13: TLabel;
    tileDay17: TRectangle;
    Circle7: TCircle;
    Label14: TLabel;
    tileDay21: TRectangle;
    Circle8: TCircle;
    Label15: TLabel;
    tileDay22: TRectangle;
    Circle9: TCircle;
    Label16: TLabel;
    tileDay23: TRectangle;
    Circle10: TCircle;
    Label17: TLabel;
    tileDay24: TRectangle;
    Circle11: TCircle;
    Label18: TLabel;
    tileDay25: TRectangle;
    Circle12: TCircle;
    Label19: TLabel;
    tileDay26: TRectangle;
    Circle13: TCircle;
    Label20: TLabel;
    tileDay27: TRectangle;
    Circle14: TCircle;
    Label21: TLabel;
    tileDay31: TRectangle;
    Circle15: TCircle;
    Label22: TLabel;
    tileDay32: TRectangle;
    Circle16: TCircle;
    Label23: TLabel;
    tileDay33: TRectangle;
    Circle17: TCircle;
    Label24: TLabel;
    tileDay34: TRectangle;
    Circle18: TCircle;
    Label25: TLabel;
    tileDay35: TRectangle;
    Circle19: TCircle;
    Label26: TLabel;
    tileDay36: TRectangle;
    Circle20: TCircle;
    Label27: TLabel;
    tileDay37: TRectangle;
    Circle21: TCircle;
    Label28: TLabel;
    tileDay41: TRectangle;
    Circle22: TCircle;
    Label29: TLabel;
    tileDay42: TRectangle;
    Circle23: TCircle;
    Label30: TLabel;
    tileDay43: TRectangle;
    Circle24: TCircle;
    Label31: TLabel;
    tileDay44: TRectangle;
    Circle25: TCircle;
    Label32: TLabel;
    tileDay45: TRectangle;
    Circle26: TCircle;
    Label33: TLabel;
    tileDay46: TRectangle;
    Circle27: TCircle;
    Label34: TLabel;
    tileDay47: TRectangle;
    Circle28: TCircle;
    Label35: TLabel;
    lYear: TLabel;
    lMonth: TLabel;
    lPrev: TLabel;
    lNext: TLabel;
    layDateChange: TLayout;
    Label40: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    lObjName: TLabel;
    lObjPlace: TLabel;
    Label46: TLabel;
    lDateFinish: TLabel;
    Layout2: TLayout;
    Label49: TLabel;
    lFileName: TLabel;
    layOpenedFile: TLayout;
    bNewTask: TRectangle;
    layDateChangeBG: TLayout;
    Image1: TImage;
    bOpenFile: TRectangle;
    Image2: TImage;
    OpenDialog: TOpenDialog;
    tileDay51: TRectangle;
    Circle29: TCircle;
    Label36: TLabel;
    tileDay52: TRectangle;
    Circle30: TCircle;
    Label37: TLabel;
    tileDay53: TRectangle;
    Circle31: TCircle;
    Label43: TLabel;
    tileDay54: TRectangle;
    Circle32: TCircle;
    Label44: TLabel;
    tileDay55: TRectangle;
    Circle33: TCircle;
    Label45: TLabel;
    tileDay56: TRectangle;
    Circle34: TCircle;
    Label47: TLabel;
    tileDay57: TRectangle;
    Circle35: TCircle;
    Label50: TLabel;
    bDateFinish: TDateEdit;
    layWork: TLayout;
    alButtons: TLayout;
    layDialog: TLayout;
    bLocations: TRectangle;
    Image3: TImage;
    bBrigada: TRectangle;
    Image4: TImage;
    bSaveData: TRectangle;
    iSave: TImage;
    iSaveOk: TImage;
    lHint: TLabel;
    layMonthGrid: TLayout;
    flLocations: TFlowLayout;
    Label39: TLabel;
    layLocations: TLayout;
    Image5: TImage;
    bSettings: TRectangle;
    Image6: TImage;
    Layout1: TLayout;
    lDateBegin: TLabel;
    bDateBegin: TDateEdit;
    Layout3: TLayout;
    Label38: TLabel;
    lSpravFilename: TLabel;
    bOpenSprav: TRectangle;
    Image7: TImage;
    OpenDialog1: TOpenDialog;
    bCreateFile: TRectangle;
    Image8: TImage;
    procedure tileDay11MouseEnter(Sender: TObject);
    procedure tileDay11MouseLeave(Sender: TObject);
    procedure tileDay11Click(Sender: TObject);
    procedure lPrevMouseEnter(Sender: TObject);
    procedure lPrevMouseLeave(Sender: TObject);
    procedure bDateFinishMouseEnter(Sender: TObject);
    procedure bDateFinishMouseLeave(Sender: TObject);
    procedure bOpenFileClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lNextClick(Sender: TObject);
    procedure lPrevClick(Sender: TObject);
    procedure bDateFinishChange(Sender: TObject);
    procedure bNewTaskClick(Sender: TObject);
    procedure bSettingsClick(Sender: TObject);
    procedure bSaveDataClick(Sender: TObject);
    procedure bBrigadaClick(Sender: TObject);
    procedure bDateBeginChange(Sender: TObject);
    procedure bOpenSpravClick(Sender: TObject);
    procedure bLocationsClick(Sender: TObject);
    procedure bCreateFileClick(Sender: TObject);
  private
    { Private declarations }
    tileSelected: TRectangle;
    procedure AttachConponents;
  public
    { Public declarations }
  end;

var
    fMain: TfMain;

implementation

{$R *.fmx}
uses
    IniFiles,
    uConst, uInterface, uTask, uSprav, uSettings, uInfo, uMessage, uQuestion,
    uWorkers, uLocation, uMission;

procedure TfMain.FormShow(Sender: TObject);
var
    ini : TIniFile;
    lastFileName, lastSprav: string;
    w, h, t, l: integer;
begin

    AttachConponents;

    /// обнуляем интерфейс (данные еще не загружены)
    AppInterface.Clear;

    /// ищем инишник с данными о последнем открытом файле и пытаемся подгрузить его
    if not FileExists(ExtractFilePath(paramstr(0)) + INI_FILE_NAME) then exit;

    ini := TIniFile.Create( ExtractFilePath(paramstr(0)) + INI_FILE_NAME );
    lastFileName := ini.ReadString('', 'LastFileName', '');
    lastSprav := ini.ReadString('', 'lastSprav', '');
    w := ini.ReadInteger('', 'Width', 0);
    h := ini.ReadInteger('', 'Height', 0);
    t := ini.ReadInteger('', 'Top', 0);
    l := ini.ReadInteger('', 'Left', 0);

    if not FileExists(lastFileName) then
    begin
        ShowMessage('Файл командировки удален или перемещен.');
        ini.WriteString('', 'LastFileName', '');
    end else
        AppInterface.LoadData( lastFileName );

    if not FileExists(lastSprav) then
    begin
        ShowMessage('Файл с данными справочников удален или перемещен.');
        ini.WriteString('', 'lastSprav', '');
    end else
        AppInterface.LoadSprav( lastSprav );

    ini.Free;

    if w <> 0 then fMain.Width := w;
    if h <> 0 then fMain.Height := h;
{
    if t <> 0 then fMain.Top := t;
    if l <> 0 then fMain.Left := l;
}
    AppInterface.LoadSettings;

    /// обновляем интерфейс (данные загружены. или нет...)
    AppInterface.Update;
end;



procedure TfMain.lNextClick(Sender: TObject);
begin
    AppInterface.NextMonth;
end;

procedure TfMain.lPrevClick(Sender: TObject);
begin
    AppInterface.PrevMonth;
end;


procedure TfMain.lPrevMouseEnter(Sender: TObject);
begin
    (Sender as TLabel).FontColor := TAlphaColorRec.Black;
end;

procedure TfMain.lPrevMouseLeave(Sender: TObject);
begin
    (Sender as TLabel).FontColor := TAlphaColorRec.Silver;
end;

procedure TfMain.bSettingsClick(Sender: TObject);
begin
    AppInterface.SetMode(MODE_SETTINGS);
end;

procedure TfMain.bOpenFileClick(Sender: TObject);
begin
    if OpenDialog1.Execute then
    begin
        if not AppInterface.LoadData( OpenDialog1.FileName ) then
        ShowMessage( 'Ошибка загрузки файла командировки.');

        AppInterface.Update;
    end;
end;

procedure TfMain.bOpenSpravClick(Sender: TObject);
begin
    if OpenDialog.Execute then
    begin
        if not AppInterface.LoadSprav( OpenDialog.FileName ) then
        ShowMessage( 'Ошибка загрузки файла с данными справочников');

        AppInterface.Update;
    end;
end;

procedure TfMain.bSaveDataClick(Sender: TObject);
begin
    AppInterface.SaveData;
end;

procedure TfMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
    ini : TIniFile;
begin
    AppInterface.SaveData;  /// сохраняем рабочие данные

    ini := TIniFile.Create( ExtractFilePath(paramstr(0)) + INI_FILE_NAME );
    ini.WriteString('', 'LastFileName', AppInterface.GetFileName);
    ini.WriteString('', 'lastSprav', AppInterface.GetSpravFileName);
    ini.WriteInteger('', 'Top', fMain.Top);
    ini.WriteInteger('', 'Left', fMain.Left);
    ini.WriteInteger('', 'Height', fMain.Height);
    ini.WriteInteger('', 'Width', fMain.Width);
    ini.Free;
end;

procedure TfMain.AttachConponents;
begin

    /// информация о командировке
    AppInterface.AttachControl('labelObjName', lObjName);
    AppInterface.AttachControl('labelObjPlace', lObjPlace);
    AppInterface.AttachControl('labelDateBegin', lDateBegin);
    AppInterface.AttachControl('labelDateFinish', lDateFinish);
    AppInterface.AttachControl('labelFileName', lFileName);
    AppInterface.AttachControl('labelSpravFileName', lSpravFilename);
    AppInterface.AttachControl('flowLocations', flLocations);

    /// отображение и управление датой
    AppInterface.AttachControl('labelYear', lYear);
    AppInterface.AttachControl('labelMonth', lMonth);
    AppInterface.AttachControl('Prev', lPrev);
    AppInterface.AttachControl('Next', lNext);

    /// кнопки
    AppInterface.AttachControl('buttonDateFinish', bDateFinish);
    AppInterface.AttachControl('buttonDateBegin', bDateBegin);
    AppInterface.AttachControl('buttonOpenFile', bOpenFile);
    AppInterface.AttachControl('buttonNewTask', bNewTask);
    AppInterface.AttachControl('buttonBrigada', bBrigada);
    AppInterface.AttachControl('buttonLocations', bLocations);
    AppInterface.AttachControl('buttonSettings', bSettings);
    AppInterface.AttachControl('buttonSaveData', bSaveData);
    AppInterface.AttachControl('iSaveOk', iSaveOk);
    AppInterface.AttachControl('labelHint', lHint);

    /// форма справочника
    AppInterface.AttachControl(FORM_SPRAV, fSprav.layout);

    /// форма сообщения
    AppInterface.AttachControl(FORM_MESSAGE, fMessage.layout);

    /// форма вопроса
    AppInterface.AttachControl(FORM_QUESTION, fQuestion.layout);

    /// сама главная форма для глобальных событий. например, вывода формы справочника
    AppInterface.AttachControl(FORM_MAIN, fMain.layDialog);

    /// рабочая зона, куда будут выводиться формы перекрывающих все главное окно режимов (сообщение, справочник,..)
    AppInterface.AttachControl('layWork', layWork);

    /// режим редактирования/создания задачи
    AppInterface.AttachControl(MODE_TASK, fTask.panel);     /// панель со всем интерфейсом
    AppInterface.AttachEvent(fTask.panel, fTask.Activate);  /// метод атоматически вызываемый при активации режма из AppInterface

    /// режим настройки отображения задач (цвет, иконка)
    AppInterface.AttachControl(MODE_SETTINGS, fSettingsForm.Layout1);
    AppInterface.AttachEvent(fSettingsForm.Layout1, fSettingsForm.Activate);/// метод атоматически вызываемый при активации режма из AppInterface

    AppInterface.AttachControl(MODE_INFO, fInfo.Layout1);
    AppInterface.AttachEvent(fInfo.Layout1, fInfo.Activate);/// метод атоматически вызываемый при активации режма из AppInterface

    /// режим редактирования/создания задачи
    AppInterface.AttachControl(MODE_WORKERS, fWorkers.Layout1);     /// панель со всем интерфейсом
    AppInterface.AttachEvent(fWorkers.Layout1, fWorkers.Activate);  /// метод атоматически вызываемый при активации режма из AppInterface

    AppInterface.AttachControl(MODE_LOCATION, fLocation.Layout1);     /// панель со всем интерфейсом
    AppInterface.AttachEvent(fLocation.Layout1, fLocation.Activate);  /// метод атоматически вызываемый при активации режма из AppInterface

    AppInterface.AttachControl(MODE_NEWMISSION, fMission.Layout1);     /// панель со всем интерфейсом
    AppInterface.AttachEvent(fMission.Layout1, fMission.Activate);  /// метод атоматически вызываемый при активации режма из AppInterface


    /// тайлы дней месяца
    AppInterface.AttachControl('Day1', tileDay11);
    AppInterface.AttachControl('Day2', tileDay12);
    AppInterface.AttachControl('Day3', tileDay13);
    AppInterface.AttachControl('Day4', tileDay14);
    AppInterface.AttachControl('Day5', tileDay15);
    AppInterface.AttachControl('Day6', tileDay16);
    AppInterface.AttachControl('Day7', tileDay17);

    AppInterface.AttachControl('Day8', tileDay21);
    AppInterface.AttachControl('Day9', tileDay22);
    AppInterface.AttachControl('Day10', tileDay23);
    AppInterface.AttachControl('Day11', tileDay24);
    AppInterface.AttachControl('Day12', tileDay25);
    AppInterface.AttachControl('Day13', tileDay26);
    AppInterface.AttachControl('Day14', tileDay27);

    AppInterface.AttachControl('Day15', tileDay31);
    AppInterface.AttachControl('Day16', tileDay32);
    AppInterface.AttachControl('Day17', tileDay33);
    AppInterface.AttachControl('Day18', tileDay34);
    AppInterface.AttachControl('Day19', tileDay35);
    AppInterface.AttachControl('Day20', tileDay36);
    AppInterface.AttachControl('Day21', tileDay37);

    AppInterface.AttachControl('Day22', tileDay41);
    AppInterface.AttachControl('Day23', tileDay42);
    AppInterface.AttachControl('Day24', tileDay43);
    AppInterface.AttachControl('Day25', tileDay44);
    AppInterface.AttachControl('Day26', tileDay45);
    AppInterface.AttachControl('Day27', tileDay46);
    AppInterface.AttachControl('Day28', tileDay47);

    AppInterface.AttachControl('Day29', tileDay51);
    AppInterface.AttachControl('Day30', tileDay52);
    AppInterface.AttachControl('Day31', tileDay53);
    AppInterface.AttachControl('Day32', tileDay54);
    AppInterface.AttachControl('Day33', tileDay55);
    AppInterface.AttachControl('Day34', tileDay56);
    AppInterface.AttachControl('Day35', tileDay57);
end;

procedure TfMain.bBrigadaClick(Sender: TObject);
begin
    AppInterface.SetMode(MODE_WORKERS);
end;

procedure TfMain.bCreateFileClick(Sender: TObject);
begin
    AppInterface.SetMode(MODE_NEWMISSION);
end;

procedure TfMain.bDateBeginChange(Sender: TObject);
begin
    AppInterface.SetDateBegin( DateToStr(bDateBegin.Date) );
end;

procedure TfMain.bDateFinishChange(Sender: TObject);
begin
    AppInterface.SetDateFinish( DateToStr(bDateFinish.Date) );
end;

procedure TfMain.bDateFinishMouseEnter(Sender: TObject);
begin
    (Sender as TRectangle).Fill.Color := TAlphaColorRec.Linen;
    if sender = bNewTask    then AppInterface.ShowHint('Создать новую задачу');
    if sender = bBrigada    then AppInterface.ShowHint('Редактирование состава бригады');
    if sender = bLocations  then AppInterface.ShowHint('Редактирование рабочих объектов');
    if sender = bSettings   then AppInterface.ShowHint('Редактирование отображения задач');
    if sender = bOpenFile   then AppInterface.ShowHint('Открытие файла командировки');
    if sender = bOpenSprav  then AppInterface.ShowHint('Открытие файла справочников');
    if sender = bCreateFile then AppInterface.ShowHint('Создание нового файла командировки');
    if sender = bSaveData   then AppInterface.ShowHint('Сохранение текущих изменений командировки');
end;

procedure TfMain.bDateFinishMouseLeave(Sender: TObject);
begin
    (Sender as TRectangle).Fill.Color := TAlphaColorRec.White;
    AppInterface.ShowHint('');
end;

procedure TfMain.bLocationsClick(Sender: TObject);
begin
    AppInterface.SetMode(MODE_LOCATION);
end;

procedure TfMain.bNewTaskClick(Sender: TObject);
begin
    AppInterface.SetMode(MODE_TASK);
end;

procedure TfMain.tileDay11Click(Sender: TObject);
begin
    AppInterface.SelectTile( sender as TControl );
end;

procedure TfMain.tileDay11MouseEnter(Sender: TObject);
begin
    (Sender as TRectangle).Stroke.Color := TAlphaColorRec.Black;
end;

procedure TfMain.tileDay11MouseLeave(Sender: TObject);
begin
    (Sender as TRectangle).Stroke.Color := TAlphaColorRec.Silver;
end;

end.
