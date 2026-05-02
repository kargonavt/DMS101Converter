unit ProgressFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, SyncObjs;

// Окно прогресса расчета
type
  TProgressForm = class(TForm)
    progressBar: TProgressBar;
    btnInterrupt: TButton;
    timer: TTimer;
    Bevel1: TBevel;
    lblProgressMessage: TLabel;
    procedure timerTimer(Sender: TObject);
    procedure btnInterruptClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

// Класс для передачи параметров прогресса из рабочего потока в окно прогресса.
// Непосредственно перед передачей данных защищается критической секцией.
  TProgress = class
  public
    m_pos, m_max: Integer;
    m_Message: string;
  end;

var
  ProgressForm: TProgressForm;
  threadList: TThreadList;  // Список критических секций
  suspendEvent: TEvent;     // Событие для приостановки рабочего потока на время
                            // принятия решения пользователем о прерывании рабочего потока
  finishedEvent: TEvent;    // Событие, сигнализирующее о завершении рабочего потока.
                            // Взводится перед выходом из Execute.
  breakEvent: TEvent;       // Событие для прерывания рабочего потока по решению пользователя

implementation

{$R *.dfm}

//uses
//  MyS101ReaderFormUnit;

///////////////////////////////////////////////////////
// TProgressForm

// Оператор нажал кнопку "Прервать"
procedure TProgressForm.btnInterruptClick(Sender: TObject);
begin
  if finishedEvent.WaitFor(0) = wrSignaled then
    Exit;
  // Приостанавливаем рабочий поток
  suspendEvent.ResetEvent;

  // В ответ на вопрос либо даем команду на прерывание рабочего потока или
  // продолжаем расчет.
  if MessageDlg('Вы действительно хотите прервать процесс?', mtConfirmation,
      [mbYes, mbNo], 0) = mrYes then begin
    lblProgressMessage.Caption := 'Идет прерывание процесса преобразования. Подождите немного...';
    progressBar.Max := 0;
    progressBar.Position := 0;
    btnInterrupt.Enabled := False;
    breakEvent.SetEvent;
  end;

  // В любом случае отпускаем поток
  suspendEvent.SetEvent;
end;

// Проверка на возможность закрыть окно
procedure TProgressForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  // Даем окну закрыться, если поток завершен. Эта проверка необходима, чтобы
  // предотвратить закрытие окна, когда поток еще работает.
  CanClose := finishedEvent.WaitFor(0) = wrSignaled;
end;

// Сработал таймер (каждые 100 мс)
procedure TProgressForm.timerTimer(Sender: TObject);
var
  progress: TProgress;
begin
  if suspendEvent.WaitFor(0) = wrTimeOut then
    Exit;
  // Если поток завершен, закрываем окно
  if finishedEvent.WaitFor(0) = wrSignaled then
    Close
  else if breakEvent.WaitFor(0) = wrTimeOut	then begin
    // Иначе устанавливаем текущие значения полосы и строки прогресса, беря их
    // из объекта класса TProgress, защищенного критической секцией.
    progress := TProgress(threadList.LockList[0]);
    progressBar.Max := progress.m_max;
    progressBar.Position := progress.m_pos;
    lblProgressMessage.Caption := progress.m_Message;
    threadList.UnlockList;
  end;
end;

begin
  // Создадим список критических секций, добавим в него объект класса TProgress
  threadList := TThreadList.Create;
  threadList.Add(TProgress.Create);
  // Создадим событие для приостановки рабочего потока на время ответа оператора
  // на вопрос о прерывании расчета. Событие с ручным сбросом, после создания взведено.
  suspendEvent := TEvent.Create(nil, True, True, 'SuspendEvent');
  finishedEvent := TEvent.Create(nil, True, False, 'FinishedEvent');
  breakEvent := TEvent.Create(nil, True, False, 'BreakEvent');
end.
