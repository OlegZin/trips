unit uMission;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit;

type
  TfMission = class(TForm)
    Layout1: TLayout;
    Label1: TLabel;
    Label3: TLabel;
    eBrigade: TEdit;
    Label4: TLabel;
    eBrigader: TEdit;
    Label5: TLabel;
    eFileName: TEdit;
    EditButton2: TEditButton;
    Button: TButton;
    Button2: TButton;
    OpenDialog1: TOpenDialog;
    procedure EditButton2Click(Sender: TObject);
    procedure ButtonClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Activate;
  end;

var
  fMission: TfMission;

implementation

{$R *.fmx}

uses uInterface, uConst;

procedure TfMission.Activate;
begin
    eBrigade.Text := '';
    eBrigader.Text := '';
    eFileName.Text := '';
end;

procedure TfMission.Button2Click(Sender: TObject);
begin
    AppInterface.SetMode(MODE_INFO);
end;

procedure TfMission.ButtonClick(Sender: TObject);
var
    mess: string;
begin
    if Trim(eBrigade.Text) = '' then mess := 'Не указано наименование бригады!';
    if Trim(eBrigader.Text) = '' then mess := mess + sLineBreak + 'Не указано имя бригадира!';
    if Trim(eFileName.Text) = '' then mess := mess + sLineBreak + 'Не указано имя файла!';

    if mess <> '' then
    begin
        AppInterface.MessageShow(mess);
        exit;
    end;

    AppInterface.onMissionCreate(eBrigade.Text, eBrigader.Text, eFileName.Text);
    AppInterface.SetMode(MODE_INFO);
end;

procedure TfMission.EditButton2Click(Sender: TObject);
begin
    if OpenDialog1.Execute then
    eFileName.Text := OpenDialog1.FileName;
end;

end.
