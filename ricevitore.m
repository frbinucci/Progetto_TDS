%% Area di Inizializzazione

clearvars;
close all;

%% Acqusizione del segnale e sincronizzazione del ricevitore.
%Lo scopo di questa sezione di codice è quello di sincronizzare il
%ricevitore, in modo da poter demodulare solo la parte di segnale "utile".
%Per poter implementare tale funzionalità si sfrutta la proprietà di
%correlazione tra sequenze. 
%Si calcola la correlazione incrociata tra una
%sequenza nota e il segnale ricevuto. L'istante di sincronizzazione sarà
%quello in cui la correlazione tra le due sequenze è massima, e sarà
%l'istante a partire dal quale il segnale ricevuto sarà demodulato.

%La sequenza nota viene ottenuta come sequenza di "Barker". Maggiori
%approfondimenti sono richiesti sul tema...
H = comm.BarkerCode('SamplesPerFrame',100000);

sequenza_nota = H();

%Vengono mostrati l'andamento temporale e lo spettro delle ampiezze della
%sequenza.
spettroSync = fft(sequenza_nota);

figure('Name','Spettro Sequenza','NumberTitle','off');
subplot(2,1,1);
plot((0:numel(sequenza_nota)-1),sequenza_nota);
grid on;
title('Andamento temporale della sequenza.');
xlabel('Tempo');
ylabel('Ampiezza');
subplot(2,1,2);
plot((0:numel(spettroSync)-1),fftshift(abs(spettroSync)));
grid on;
title('Spettro della sequenza');
xlabel('Frequenza');
ylabel('Ampiezza');

%Il segnale in ricezione viene acquisito tramite microfono.
%Definizione del tempo di registrazione (10 secondi).
tempo_acquisizione = 20;
%Definizione della frequenza di campionamento necessaria.
frequenza_campionamento = 50000;
%Definizione dell'oggetto necessario alla registrazione dell'audio.
rec = audiorecorder(frequenza_campionamento,16,1);

%Acquizione dell'audio tramite il microfono del computer.
record(rec, tempo_acquisizione); 
pause(tempo_acquisizione+1); 
stop(rec);

%Ottenimento del vettore contenente i campioni del segnale, mediante la
%funzione "getadiodata()".
ricevuto = getaudiodata(rec);

%% Sincronizzazione del ricevitore. 
% In questa fase si attua il processo di sincronizzazione vero e proprio.

%Calcolo della correlazione incrociata tra il segnale ricevuto e la
%sequenza di Barker.
[correlazione_ricevuto,lag] = xcorr(sequenza_nota,ricevuto);

%Sintassi leggermente oscura...In ogni caso ottengo il valore massimo della
%correlazione e l'istante in cui esso si verifica. Tale istante temporale
%segnerà il momento in cui dovrà iniziare la demodulazione del segnale
%ricevuto.
[~,I] = max(abs(correlazione_ricevuto));
lagDiff = lag(I);

%La funzione "lag()" restituisce il ritardo in termini di numero di
%campione. Dividendo per la frequenza di campionamento ottengo l'istante
%temporale
timeDiff = lagDiff/frequenza_campionamento;

%Prendo il valore assoluto del ritardo e lo approssimo all'intero più
%grande più vicino.
ritardo = abs(timeDiff);
ritardo = ceil(ritardo);

%Il vettore "segnale_utile" conterrà solo la parte di segnale ricevuto a
%partire dall'istante di sincronizzazione, e sarà quello che verrà
%demodulato.
segnale_utile = ricevuto(round(frequenza_campionamento)*ritardo+1:end);

%Ottenimento del grafico della funzione di cross-correlazione.
figure('Name','Correlazione','NumberTitle','off');
plot((0:numel(correlazione_ricevuto)-1)/frequenza_campionamento,correlazione_ricevuto);
title('Correlazione Incrociata');
grid on;
xlabel('Tempo (s)');
ylabel('Ampiezza');

%Riproduco il segnale utile...
%sound(segnale_utile,frequenza_campionamento);


%% Demodulazione del segnale
%In questa parte dello script ci si occupa di demodulare il segnale utile.
frequenza_modulazione = 8000;
segnale_ricevuto = ssbdemod(segnale_utile,frequenza_modulazione,frequenza_campionamento);

%Analisi spettrale del segnale ricevuto.
%--------------------------------------------------------------------------
    %Under Construction!
%--------------------------------------------------------------------------

%Riproduco il segnale demodulato per verificare che l'informazione sia
%stata ricevuta correttamente.
sound(segnale_ricevuto,frequenza_campionamento);
