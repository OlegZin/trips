unit uLocation;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, superobject, FMX.Edit,
  FMX.Objects;

type
  TfLocation = class(TForm)
    Layout1: TLayout;
    Label1: TLabel;
    lNoTasks: TLabel;
    eObjectName: TEdit;
    EditButton1: TEditButton;
    Label2: TLabel;
    eObjectPlace: TEdit;
    EditButton2: TEditButton;
    eZavNum: TEdit;
    Label3: TLabel;
    AddLocation: TCircle;
    Image4: TImage;
    layFlow: TFlowLayout;
    Label4: TLabel;
    Button2: TButton;
    Button1: TButton;
    procedure EditButton1Click(Sender: TObject);
    procedure EditButton2Click(Sender: TObject);
    procedure AddLocationClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    data: ISuperObject;
    selID: Integer;

    ObjectName,
    ObjectPlace,
    ZavNum
            : string;
    ObjectPlaceID
            : integer;

    procedure onClick(sender: TObject);
    procedure onLocationDel(sender: TObject);
    procedure SpravResult(name: string; indata: ISuperObject);
  public
    { Public declarations }
     procedure Activate;
     procedure Update;
  end;

var
  fLocation: TfLocation;

implementation

{$R *.fmx}

uses uInterface, uAtlas, uConst, uData;

{ TfLocation }

procedure TfLocation.Activate;
begin
    data := AppInterface.onLocationActivate;

    ObjectName := '';
    ObjectPlace := '';
    ZavNum := '';
    ObjectPlaceID := 0;

    update;
end;

procedure TfLocation.AddLocationClick(Sender: TObject);
var
    mess: string;
    item: ISuperObject;
begin

    if Trim(eObjectName.Text) = '' then mess := mess + 'Не указано наименование объекта!';
    if Trim(eObjectPlace.Text) = '' then mess := mess + sLineBreak + 'Не указано местоположение объекта!';
    if Trim(eZavNum.Text) = '' then mess := mess + sLineBreak + 'Не указан заводской номер!';

    if mess <> '' then
    begin
        AppInterface.MessageShow(mess);
        exit;
    end;

    /// добавляем новый элемент в список
    item := AppData.GetNewLocation(eObjectName.Text, eObjectPlace.Text, eZavNum.Text, ObjectPlaceID);
    data.O[ item.S['id'] ] := item;

    ObjectName := '';
    ObjectPlace := '';
    ZavNum := '';
    ObjectPlaceID := 0;

    /// обновляем список
    Update;
end;

procedure TfLocation.Button1Click(Sender: TObject);
begin
    AppInterface.onLocationSave(data);
end;

procedure TfLocation.Button2Click(Sender: TObject);
begin
    AppInterface.SetMode(MODE_INFO);
end;

procedure TfLocation.EditButton1Click(Sender: TObject);
begin
    AppInterface.onSpravRequest( SpravResult, SPRAV_OBJECTS );
end;

procedure TfLocation.EditButton2Click(Sender: TObject);
begin
    AppInterface.onSpravRequest( SpravResult, SPRAV_PLACES );
end;

procedure TfLocation.onClick(sender: TObject);
begin
    selID := (Sender as TControl).Tag;
    update;
end;

procedure TfLocation.onLocationDel(sender: TObject);
var
    id : integer;
begin
    id := (Sender as TControl).Tag;
    data.B[IntToStr(id)+'.Deleted'] := true;
    update;
end;

procedure TfLocation.SpravResult(name: string; indata: ISuperObject);
begin
    if name = SPRAV_OBJECTS then
    begin
       ObjectName := indata.S['name'];
    end;

    if name = SPRAV_PLACES then
    begin
       ObjectPlace := indata.S['name'];
       ObjectPlaceID := indata.I['id'];
    end;

    Update;
end;

procedure TfLocation.Update;
var
   loc: ISuperObject;
   cnt: TControl;
   i: integer;
begin
    if not Assigned(data) then exit;

    /// чистим список
    for I := layFlow.ControlsCount-1 downto 0 do
    layFlow.Controls[i].Free;

    for loc in data do                                        /// перебираем участников бригады
    if not loc.B['Deleted'] then
    begin
        /// клонируем болванку элемента списка
        cnt := fAtlas.layLocation.Clone(layFlow) as TControl;
        cnt.Parent := layFlow;
        cnt.Width := layFlow.Width-100;
        cnt.Tag := loc.I['id'];
        cnt.HitTest := true;
        cnt.OnClick := onClick;

        /// перебираем элементы шаблона
        if Assigned(cnt) then
        for i := 0 to cnt.ComponentCount-1 do
        begin

            if cnt.Components[i].Tag = LOC_NAME
            then (cnt.Components[i] as TLabel).Text := loc.S['ObjectName'] + ' ( Зав.№ ' + loc.S['ZavNum'] + ' )';

            if cnt.Components[i].Tag = LOC_POS
            then (cnt.Components[i] as TLabel).Text := loc.S['ObjectPlace'];

            if cnt.Components[i].Tag = LOC_DEL then
            begin
                cnt.Components[i].Tag := loc.I['id'];
                (cnt.Components[i] as TControl).OnClick := onLocationDel;
            end;

            if cnt.Components[i].Tag = LOC_BG then
            if selID = loc.I['id']
            then (cnt.Components[i] as TRectangle).Fill.Kind := TBrushKind.Solid
            else (cnt.Components[i] as TRectangle).Fill.Kind := TBrushKind.None;

        end;

    end;

    eObjectName.Text := ObjectName;
    eObjectPlace.Text := ObjectPlace;
    eZavNum.Text := ZavNum;

end;

end.
