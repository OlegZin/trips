program TimesheetSolo;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'uMain.pas' {fMain},
  uData in 'uData.pas',
  superdate in 'SuperObject\superdate.pas',
  superobject in 'SuperObject\superobject.pas',
  supertimezone in 'SuperObject\supertimezone.pas',
  supertypes in 'SuperObject\supertypes.pas',
  superxmlparser in 'SuperObject\superxmlparser.pas',
  uConst in 'uConst.pas',
  uInterface in 'uInterface.pas',
  uTask in 'uTask.pas' {fTask},
  uSprav in 'uSprav.pas' {fSprav},
  uSettings in 'uSettings.pas' {fSettingsForm},
  uAtlas in 'uAtlas.pas' {fAtlas},
  uInfo in 'uInfo.pas' {fInfo},
  uQuestion in 'uQuestion.pas' {fQuestion},
  uMessage in 'uMessage.pas' {fMessage},
  uWorkers in 'uWorkers.pas' {fWorkers},
  uLocation in 'uLocation.pas' {fLocation},
  uMission in 'uMission.pas' {fMission};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(TfTask, fTask);
  Application.CreateForm(TfSprav, fSprav);
  Application.CreateForm(TfSettingsForm, fSettingsForm);
  Application.CreateForm(TfAtlas, fAtlas);
  Application.CreateForm(TfInfo, fInfo);
  Application.CreateForm(TfQuestion, fQuestion);
  Application.CreateForm(TfMessage, fMessage);
  Application.CreateForm(TfWorkers, fWorkers);
  Application.CreateForm(TfLocation, fLocation);
  Application.CreateForm(TfMission, fMission);
  Application.Run;
end.
