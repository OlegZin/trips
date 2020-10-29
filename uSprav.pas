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
    Выбрать: TButton;
    Button2: TButton;
    Rectangle2: TRectangle;
    lCount: TLabel;
    procedure ВыбратьClick(Sender: TObject);
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
/// получаем данные выбраннго элемента и отдаем в обработчик
var
    item: ISuperObject;
begin
    /// находим объект, который нужно вернуть
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

    /// заполнение справочника с ограничением по количеству, если он очень объемный
    for item in data do
    begin
        if (filter = '') or                                                 /// фильтр отсутствует
           ((filter <> '') and (Pos(Edit1.Text, item.S['name']) > 0)) then  /// либо установлен и есть совпадение
        begin
            ListBox1.Items.Add( item.S['name'] );
            Inc(count);
        end;

        if count = SPRAV_SHOW_LINES_COUNT then break;
    end;

    if ListBox1.Count = SPRAV_SHOW_LINES_COUNT
    then lCount.Text := 'Записей: более ' + intToStr(SPRAV_SHOW_LINES_COUNT)
    else lCount.Text := 'Записей: ' + intToStr(ListBox1.Count);

    Edit1.ReadOnly := false;
end;

procedure TfSprav.ВыбратьClick(Sender: TObject);
begin
    GetData;
end;

end.
