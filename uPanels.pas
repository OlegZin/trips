unit uPanels;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Edit, FMX.Layouts, FMX.ListBox;

type
  TfPanels = class(TForm)
    pNone: TRectangle;
    Label2: TLabel;
    pInfo: TRectangle;
    Label1: TLabel;
    pTask: TRectangle;
    Label3: TLabel;
    Edit1: TEdit;
    Label4: TLabel;
    EditButton1: TEditButton;
    Edit2: TEdit;
    Label5: TLabel;
    Edit3: TEdit;
    Label6: TLabel;
    ListBox1: TListBox;
    Button1: TButton;
    Button2: TButton;
    cbAutoUsed: TCheckBox;
    Label7: TLabel;
    Edit4: TEdit;
    EditButton2: TEditButton;
    Edit5: TEdit;
    EditButton3: TEditButton;
    Label8: TLabel;
    Edit6: TEdit;
    EditButton4: TEditButton;
    Label9: TLabel;
    Edit7: TEdit;
    EditButton5: TEditButton;
    Label10: TLabel;
    cbLivingUsed: TCheckBox;
    Edit8: TEdit;
    EditButton6: TEditButton;
    Label11: TLabel;
    Label12: TLabel;
    Edit9: TEdit;
    Button3: TButton;
    Button4: TButton;
    layMainBlock: TLayout;
    layAuto: TLayout;
    layLiving: TLayout;
    layButtons: TLayout;
    procedure cbAutoUsedChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdatePanels;
  end;

var
  fPanels: TfPanels;

implementation

{$R *.fmx}

uses
    uInterface;

procedure TfPanels.Button3Click(Sender: TObject);
begin
    AppInterface.SetMode(MODE_INFO);
end;

procedure TfPanels.cbAutoUsedChange(Sender: TObject);
begin
    UpdatePanels;
end;

procedure TfPanels.FormCreate(Sender: TObject);
begin
    UpdatePanels;
end;

procedure TfPanels.UpdatePanels;
begin
    if cbAutoUsed.IsChecked
    then layAuto.AnimateFloat('Height', label10.Position.Y + label10.Height + 20, 0.1, TAnimationType.&In, TInterpolationType.Linear)
    else layAuto.AnimateFloat('Height', 0, 0.1, TAnimationType.&In, TInterpolationType.Linear);

    if cbLivingUsed.IsChecked
    then layLiving.AnimateFloat('Height', label12.Position.Y + label12.Height + 20, 0.1, TAnimationType.&In, TInterpolationType.Linear)
    else layLiving.AnimateFloat('Height', 0, 0.1, TAnimationType.&In, TInterpolationType.Linear);
end;

end.
