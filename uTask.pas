unit uTask;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Edit, FMX.Layouts, FMX.ListBox,
  superobject,
  uConst;

type
  TfTask = class(TForm)
    pNone: TRectangle;
    panel: TRectangle;
    Label3: TLabel;
    WorkType: TEdit;
    Label4: TLabel;
    EditButton1: TEditButton;
    Nomenkl: TEdit;
    Label5: TLabel;
    ReasonType: TEdit;
    Label6: TLabel;
    Reasons: TListBox;
    Button1: TButton;
    Button2: TButton;
    AutoUsed: TCheckBox;
    Label7: TLabel;
    IdleAct: TEdit;
    EditButton2: TEditButton;
    AutoNumber: TEdit;
    EditButton3: TEditButton;
    Label8: TLabel;
    Driver: TEdit;
    EditButton4: TEditButton;
    Label9: TLabel;
    Organization: TEdit;
    EditButton5: TEditButton;
    Label10: TLabel;
    LivingUsed: TCheckBox;
    PayType: TEdit;
    EditButton6: TEditButton;
    Label11: TLabel;
    Label12: TLabel;
    Summa: TEdit;
    bCancel: TButton;
    bClear: TButton;
    layMainBlock: TLayout;
    layAuto: TLayout;
    layLiving: TLayout;
    layButtons: TLayout;
    bSave: TButton;
    EditButton7: TEditButton;
    Label1: TLabel;
    procedure AutoUsedChange(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure bClearClick(Sender: TObject);
    procedure bSaveClick(Sender: TObject);
    procedure WorkTypeKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure WorkTypeChange(Sender: TObject);
    procedure WriteToData(Sender: TObject);
    procedure EditButton1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure EditButton5Click(Sender: TObject);
    procedure EditButton4Click(Sender: TObject);
    procedure EditButton3Click(Sender: TObject);
    procedure EditButton2Click(Sender: TObject);
    procedure EditButton6Click(Sender: TObject);
    procedure EditButton7Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);

  private
    { Private declarations }
    data: ISuperObject;

  public
    { Public declarations }

    procedure Update;
    procedure ClearForm;
    procedure Activate;
    procedure SpravResult(name: string; indata: ISuperObject);
                             /// ����� ��������� ���������� ������ �����������
  end;

var
  fTask: TfTask;

implementation

{$R *.fmx}

uses
    uInterface, uData;

procedure TfTask.bCancelClick(Sender: TObject);
begin
    /// ��������� �������� ����������� ������ ��������/��������������
    AppInterface.onTaskCancel;
end;

procedure TfTask.bSaveClick(Sender: TObject);
var
    mess: string;
begin

    mess := '';

    /// �������� ������������ ���������� ������
    /// (��������� ������ ������������� ��������� TASK_SHABLON)
    if data.S['WorkType'] = ''                              then mess := mess + '�� ������ ��� �����!' + sLineBreak;
    if (data.S['ReasonType'] <> '��������� �� ���������') and
       (data.S['Nomenkl'] = '')                             then mess := mess + '�� ������� �������������� ������!' + sLineBreak;

    if data.B['AutoUsed'] and (data.S['Organization'] = '') then mess := mess + '�� ������� ���������������� �����������!' + sLineBreak;
    if data.B['AutoUsed'] and (data.S['Driver'] = '')       then mess := mess + '�� ������ ��������!' + sLineBreak;
    if data.B['AutoUsed'] and (data.S['AutoNumber'] = '')   then mess := mess + '�� ������ ����� ������!' + sLineBreak;

    if data.B['LivingUsed'] and (data.S['PayType'] = '')    then mess := mess + '�� ������ ��� ������ ���������!' + sLineBreak;
    if data.B['LivingUsed'] and (data.S['Summa'] = '')      then mess := mess + '�� ������� ����� ���������!' + sLineBreak;
    if data.B['LivingUsed'] and (StrToFloatDef(data.S['Summa'], 0) = 0)
                                                            then mess := mess + '������� �� ���������� ����� ���������!' + sLineBreak;

    if mess <> '' then
    begin
        AppInterface.MessageShow(mess);
        exit;
    end;

    /// ��������� �������� ����������� ��������/��������������
    AppInterface.onTaskCreate(data);
end;



procedure TfTask.bClearClick(Sender: TObject);
begin
    ClearForm;
end;

procedure TfTask.AutoUsedChange(Sender: TObject);
begin
    data.B[(sender as TComponent).name] := (sender as TCheckBox).IsChecked;
    Update;
end;

procedure TfTask.ClearForm;
var
    id: string;  /// ������ ��� �������� ������ id ������
begin
    /// �������� ������
    data := SO(TASK_SHABLON);
    data.S['id'] := id;
    /// ��������� ���������
    Update;
end;

procedure TfTask.Button1Click(Sender: TObject);
var
    I: Integer;
begin
    if Reasons.ItemIndex = -1 then exit;
    for I := 0 to data.A['Reasons'].Length-1 do
    if data.A['Reasons'][i].S['name'] = Reasons.Items[Reasons.ItemIndex] then
    begin
        data.Delete('Reasons['+IntToStr(I)+']');
        break;
    end;
    Update;
end;

procedure TfTask.Button2Click(Sender: TObject);
begin
    if Assigned(data.O['ReasonSprav']) and (data.S['ReasonSprav'] <> '') then
    AppInterface.onSpravRequest( SpravResult, data.S['ReasonSprav'] );
end;

procedure TfTask.EditButton1Click(Sender: TObject);
begin
    AppInterface.onSpravRequest( SpravResult, SPRAV_WORKTYPES );
end;

procedure TfTask.EditButton2Click(Sender: TObject);
begin
    AppInterface.onSpravRequest( SpravResult, SPRAV_IDLEACT );
end;

procedure TfTask.EditButton3Click(Sender: TObject);
begin
    AppInterface.onSpravRequest( SpravResult, SPRAV_AUTOS );
end;

procedure TfTask.EditButton4Click(Sender: TObject);
begin
    AppInterface.onSpravRequest( SpravResult, SPRAV_DRIVERS );
end;

procedure TfTask.EditButton5Click(Sender: TObject);
begin
    AppInterface.onSpravRequest( SpravResult, SPRAV_ORGANIZATIONS );
end;

procedure TfTask.EditButton6Click(Sender: TObject);
begin
    AppInterface.onSpravRequest( SpravResult, SPRAV_PAYTYPES );
end;

procedure TfTask.EditButton7Click(Sender: TObject);
begin
    if data.S['ReasonType'] = '��������� �� ���������' then exit;
    AppInterface.onSpravRequest( SpravResult, SPRAV_NOMENKL );
end;

procedure TfTask.SpravResult(name: string; indata: ISuperObject);
/// ������������ ������ ���������� �� �����������
begin
    if not Assigned(data) then exit;

    /// ������������ ��������� ������ �� ����� �����������
    if name = SPRAV_WORKTYPES then
    begin
        /// ���� ��� ������ �� ��������� - ����������
        if data.S['WorkType'] = indata.S['name'] then exit;

       { /// ������������ ������ (data):
        "id": 0,
        "Reason": "����������� � ��������� ��������� � ����",
        "AccExpens": 20,
        "sprav": "OffersClaims",
        "name": "�� - ���������� ���������",
        "smallname": "��"
       }

       data.S['WorkType'] := indata.S['name'];     /// ������������� ��� ������
       data.I['WorkTypeID'] := indata.I['id'];
       data.S['Nomenkl'] := '';                    /// ���������� �������� �������. ������
       data.I['NomenklID'] := 0;
       data.S['ReasonType'] := indata.S['Reason']; /// ������������� ��� ���������
       data.S['ReasonSprav'] := indata.S['sprav'];            /// ������������� ���������� ������ ���������
       data.A['Reasons'].Clear(true);              /// ������ ������ ���������
    end;

    if name = SPRAV_NOMENKL then
    begin
       data.S['Nomenkl'] := indata.S['name'];
       data.I['NomenklID'] := indata.I['id'];
    end;

    if (name = SPRAV_OFFERSSERVICES) or (name = SPRAV_OFFERSCLAIMS) or (name = SPRAV_INKOMPLINSTALL) then
    begin
       data['Reasons[]'] := indata;
    end;

    if name = SPRAV_ORGANIZATIONS then
    begin
       data.S['Organization'] := indata.S['name'];
       data.I['OrganizationID'] := indata.I['id'];
    end;

    if name = SPRAV_DRIVERS then
    begin
       data.S['Driver'] := indata.S['name'];
       data.I['DriverID'] := indata.I['id'];
    end;

    if name = SPRAV_AUTOS then
    begin
       data.S['AutoNumber'] := indata.S['name'];
       data.I['AutoNumberID'] := indata.I['id'];
    end;

    if name = SPRAV_IDLEACT then
    begin
       data.S['IdleAct'] := indata.S['name'];
       data.I['IdleActID'] := indata.I['id'];
    end;

    if name = SPRAV_PAYTYPES then
    begin
       data.S['PayType'] := indata.S['name'];
    end;

    Update;
end;

procedure TfTask.Activate;
begin
    // �������� ������
    data := AppInterface.onTaskActivate;

    /// �������� ������� ������, ���� �� ������
    if not Assigned(data) then
    begin
        data := SO(TASK_SHABLON);
        data.I['ID'] := AppData.GetNewTaskID;
    end;

    Update;
end;

procedure TfTask.Update;
var
    i: integer;
    item: ISuperObject;
begin
    /// ���������� ���������� �� �����
    for I := 0 to ComponentCount-1 do
    begin
        /// ���� ���� ������ � ����� �� ������, ����� ������� ������ � ���������
        if Assigned(data.O[Components[i].Name]) then
        begin
            // ������ �������� ������ �� ���� ����������
            if Components[i] is TEdit then (Components[i] as TEdit).Text := data.S[Components[i].Name];
            if Components[i] is TCheckBox then (Components[i] as TCheckBox).IsChecked := data.B[Components[i].Name];

            if Components[i] is TListBox then
            begin
                if Assigned(data.O[ Components[i].Name ]) then
                begin
                    (Components[i] as TListBox).Items.Clear;

                    for item in data.O[ Components[i].Name ] do
                    (Components[i] as TListBox).Items.Add( item.S['name'] );
                end;
            end;
        end;
    end;


    if AutoUsed.IsChecked
    then layAuto.AnimateFloat('Height', label10.Position.Y + label10.Height + 20, ANIMATION_SPEED)
    else layAuto.AnimateFloat('Height', 0, ANIMATION_SPEED);

    if LivingUsed.IsChecked
    then layLiving.AnimateFloat('Height', label12.Position.Y + label12.Height + 20, ANIMATION_SPEED)
    else layLiving.AnimateFloat('Height', 0, ANIMATION_SPEED);
end;

procedure TfTask.WorkTypeChange(Sender: TObject);
begin
    WriteToData(Sender);
end;

procedure TfTask.WorkTypeKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
    WriteToData(Sender);
end;

procedure TfTask.WriteToData(Sender: TObject);
begin
    /// ����� ������ � ������, ��� ����� ������
    if Assigned(data.O[(Sender as TControl).Name])
    then data.S[(Sender as TControl).Name] := (Sender as TEdit).Text;
end;

end.
