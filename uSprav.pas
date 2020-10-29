unit uSprav;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.ListBox, FMX.Controls.Presentation, FMX.Edit, FMX.Objects,
  uConst, superobject;

type
  TfSprav = class(TForm)
    layout: TLayout;
    Rectangle1: TRectangle;
    Edit1: TEdit;
    ListBox1: TListBox;
    �������: TButton;
    Button2: TButton;
    Rectangle2: TRectangle;
    lCount: TLabel;
    procedure �������Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Edit1KeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure ListBox1DblClick(Sender: TObject);
  private
    { Private declarations }
    data: ISuperObject;
    selected: ISuperObject;

    procedure UpdateList(filter: string);
    procedure GetData;
  public
    { Public declarations }
    procedure ShowSprav(_data: ISuperObject);
  end;

var
  fSprav: TfSprav;

implementation

{$R *.fmx}

uses uInterface;

{ TfSprav }

procedure TfSprav.Button2Click(Sender: TObject);
begin
    AppInterface.onSpravCancel;
end;

procedure TfSprav.Edit1KeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
    if Length(Edit1.Text) >= SPRAV_LETTERS_COUNT
    then UpdateList( Edit1.Text )
    else UpdateList( '' )
end;

procedure TfSprav.GetData;
/// �������� ������ ��������� �������� � ������ � ����������
var
    item: ISuperObject;
begin
    /// ������� ������, ������� ����� �������
    for item in data do
    if item.S['name'] = ListBox1.Items[ListBox1.ItemIndex] then
    begin
        selected := item;
        break;
    end;

    ListBox1.Items.Clear;

    AppInterface.onSpravSelect( selected );
end;

procedure TfSprav.ListBox1DblClick(Sender: TObject);
begin
    GetData;
end;

procedure TfSprav.ShowSprav(_data: ISuperObject);
begin
    if not Assigned(_data) then exit;

    data := _data;

    Edit1.Text := '';

    UpdateList('');

end;

procedure TfSprav.UpdateList(filter: string);
var
    item: ISuperObject;
    count: integer;
begin
    count := 0;

    Edit1.ReadOnly := true;

    ListBox1.Items.Clear;

    /// ���������� ����������� � ������������ �� ����������, ���� �� ����� ��������
    for item in data do
    begin
        if (filter = '') or                                                 /// ������ �����������
           ((filter <> '') and (Pos(Edit1.Text, item.S['name']) > 0)) then  /// ���� ���������� � ���� ����������
        begin
            ListBox1.Items.Add( item.S['name'] );
            Inc(count);
        end;

        if count = SPRAV_SHOW_LINES_COUNT then break;
    end;

    if ListBox1.Count = SPRAV_SHOW_LINES_COUNT
    then lCount.Text := '�������: ����� ' + intToStr(SPRAV_SHOW_LINES_COUNT)
    else lCount.Text := '�������: ' + intToStr(ListBox1.Count);

    Edit1.ReadOnly := false;
end;

procedure TfSprav.�������Click(Sender: TObject);
begin
    GetData;
end;

end.
