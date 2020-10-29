unit uMessage;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts,
  uConst, superobject;

type
  TfMessage = class(TForm)
    layout: TLayout;
    Rectangle2: TRectangle;
    rectMess: TRectangle;
    Button2: TButton;
    Label1: TLabel;
    layTextContainer: TLayout;
    layPadding: TLayout;
    Circle1: TCircle;
    Label2: TLabel;
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Activate(text: string);
  end;

var
  fMessage: TfMessage;

implementation

{$R *.fmx}

uses uInterface;

procedure TfMessage.Activate(text: string);
begin
    // подгоняем ширину и высоту контейнера по тексту
    Label1.Text := text;
    Label1.Width := layTextContainer.Width;
    layTextContainer.Height := Label1.Height;

    // корректируем высоту окна
    rectMess.Height := layPadding.Height * 3 + Label1.Height + Button2.Height;
end;

procedure TfMessage.Button2Click(Sender: TObject);
begin
    AppInterface.onMessClose;
end;

end.
