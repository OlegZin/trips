unit uSettings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Colors,
  uConst, System.ImageList, FMX.ImgList,
  superobject;


type
  TfSettingsForm = class(TForm)
    Layout1: TLayout;
    ColorPanel1: TColorPanel;
    Button1: TButton;
    ListBox: TListBox;
    ImageList1: TImageList;
    layFlow: TFlowLayout;
    Label1: TLabel;
    Button2: TButton;
    procedure onMouseEnter(Sender: TObject);
    procedure onMouseLeave(Sender: TObject);
    procedure onClick(Sender: TObject);
    procedure ColorPanel1Change(Sender: TObject);
    procedure ListBoxChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    data: ISuperObject;
    selected: TControl;
    size: TSizeF;
    procedure Update;

  public
    { Public declarations }
    procedure Activate;
  end;

var
  fSettingsForm: TfSettingsForm;

implementation

{$R *.fmx}

uses uInterface;

{ TfSettings }

procedure TfSettingsForm.Activate;
var
    i : integer;
begin
    /// при инициализации забиваем картинками
    if ListBox.Items.Count = 0 then
    for I := 0 to ImageList1.Count-1 do
    begin
        ListBox.Items.Add('');
        ListBox.ListItems[ListBox.Items.Count-1].StyleLookup := 'listboxitembottomdetail';
        ListBox.ListItems[ListBox.Items.Count-1].ImageIndex := i;
    end;

    /// получаем данные от внешнего источника, если прив€зан
    data := AppInterface.onSettingsActivate;

    selected := nil;

    Update;
end;

procedure TfSettingsForm.onMouseLeave(Sender: TObject);
begin
    if sender <> selected then
    (sender as TShape).Stroke.Kind := TBrushKind.None;
end;

procedure TfSettingsForm.Button1Click(Sender: TObject);
begin
    AppInterface.onSettingsSave(data);
end;

procedure TfSettingsForm.Button2Click(Sender: TObject);
begin
    AppInterface.onSettingsCancel;
end;

procedure TfSettingsForm.ColorPanel1Change(Sender: TObject);
begin
    if Assigned(selected) then
    begin
        (selected as TShape).Fill.Color := ColorPanel1.Color;
        data.I[IntToStr(selected.Tag)+'.color'] := ColorPanel1.Color;
    end;
end;

procedure TfSettingsForm.ListBoxChange(Sender: TObject);
begin
    ImageList1.ComponentIndex;
    if assigned(selected) then
    begin
        (selected.Controls[0].Controls[0] as TImage).Bitmap.Assign( ImageList1.Bitmap(size, ListBox.ItemIndex) );
        (selected.Controls[0].Controls[0] as TControl).Tag := ListBox.ItemIndex;
        data.I[IntToStr(selected.Tag)+'.icon'] := ListBox.ItemIndex;
    end;
end;

procedure TfSettingsForm.onClick(Sender: TObject);
begin
    /// разбираемс€ с визуальной обработкой
    if Assigned(selected) then
    (selected as TShape).Stroke.Kind := TBrushKind.None;

    selected := Sender as TControl;
    (sender as TShape).Stroke.Color := TAlphaColorRec.Black;

    /// отображаем цвет фона
    ColorPanel1.Color := (sender as TShape).Fill.Color;

    /// выдел€ем текущую выбранную иконку
    ListBox.ItemIndex := ((sender as TControl).Controls[0].Controls[0] as TControl).Tag;
end;

procedure TfSettingsForm.onMouseEnter(Sender: TObject);
begin
    if sender <> selected
    then (sender as TShape).Stroke.Color := TAlphaColorRec.Gray
    else (sender as TShape).Stroke.Color := TAlphaColorRec.Black;

    (sender as TShape).Stroke.Kind := TBrushKind.Solid;
end;

procedure TfSettingsForm.Update;
var
    i : integer;
    item : ISuperObject;
    rect : TRectangle;
    circ: TCircle;
    img: TImage;
    lab: TLabel;
begin
    size.cx := 36;
    size.cy := 36;

    for I := layFlow.ControlsCount-1 downto 0 do
    layFlow.Controls[i].Free;

    for item in data do
    begin
        rect := TRectangle.Create(nil);
        rect.Parent := layFlow;
        rect.Height := TASK_LAYER_MAX_HEIGHT;
        rect.Width := layFlow.Width;
        rect.Fill.Color := TColor(item.I['color']);
        rect.Stroke.Kind := TBrushKind.None;
        rect.XRadius := 10;
        rect.YRadius := 10;
        rect.Margins.Bottom := 3;
        rect.Margins.Right := 3;
        rect.OnMouseEnter := onMouseEnter;
        rect.OnMouseLeave := onMouseLeave;
        rect.OnClick := onClick;

        rect.Tag := item.I['id'];


        /// создаем кружок дл€ отображени€ типа задачи
        circ := TCircle.Create(nil);
        circ.Width := rect.Height-4;
        circ.Height := rect.Height-4;
        circ.Margins.Left := 2;
        circ.Fill.Color := TAlphaColorRec.White;
        circ.Stroke.Kind := TBrushKind.None;
        circ.Align := TAlignLayout.Left;
        circ.Parent := rect;
        circ.HitTest := false;

        /// пихаем в кружок картинку типа задачи
        img := TImage.Create(nil);
        img.Bitmap.Assign( ImageList1.Bitmap(size, item.I['icon']) );
        img.Align := TAlignLayout.Client;
        img.Margins.Left := 2;
        img.Margins.Right := 2;
        img.Margins.Top := 2;
        img.Margins.Bottom := 2;
        img.Parent := circ;
        img.HitTest := false;
        img.Tag := item.I['icon'];

        lab := TLabel.Create(nil);
        lab.Parent := rect;
        lab.Text := item.S['name'];
        lab.Align := TAlignLayout.Client;
        lab.TextSettings.VertAlign := TTextAlign.Center;
        lab.TextSettings.Font.Style := lab.TextSettings.Font.Style + [TFontStyle.fsBold];
        lab.Margins.Left := 10;
    end;
end;

end.
