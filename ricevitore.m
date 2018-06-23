%% Area di Inizializzazione

clearvars;
close all;

%% Area di presentazione.
%In questa sezione vengono mostrate le istruzioni utili per il
%funzionamento dello script.
disp("Premere invic per procedere con l'acquisizione del segnale... (l'acquisizione del segnale dura 15 secondi).");
pause();
%% Definizione del filtro necessario al filtraggio del segnale demodulato. 
% Il segnale demodulato viene nuovamente filtrato passa-basso, in modo da
% eliminarne tutte le componenti frequenziali superiori ai 4KHz. Viene
% utilizzato il medesimo filtro impiegato nello script di Modulazione.

%Definizione della frequenza di campionamento.
frequenza_campionamento = 50000;

fpass = 4000; %%Limite banda passante.
fstop = 4500; %%Limite banda di transisione.
Apass = 1; %%Ripple in banda passante. (dB).
Astop = 45; %%Ripple in banda di transizione (dB).

risposta_impulsiva = generaRisposta(fpass,fstop,Apass,Astop,frequenza_campionamento);

%% Acqusizione del segnale e sincronizzazione del ricevitore.
%Lo scopo di questa sezione di codice è quello di sincronizzare il
%ricevitore, in modo da poter demodulare solo la parte di segnale "utile".
%Per poter implementare tale funzionalità si sfrutta la proprietà di
%correlazione tra sequenze. 
%Si calcola la correlazione incrociata tra una
%sequenza nota e il segnale ricevuto. L'istante di sincronizzazione sarà
%quello in cui la correlazione tra le due sequenze è massima, e sarà
%l'istante a partire dal quale il segnale ricevuto sarà demodulato.

%La sequenza nota viene ottenuta come sequenza di "Barker".
H = comm.BarkerCode('SamplesPerFrame',10000);

sequenza_nota = H();

%Il segnale in ricezione viene acquisito tramite microfono.
%Definizione del tempo di registrazione (10 secondi).
tempo_acquisizione = 15;
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
segnale_utile = ricevuto(round(frequenza_campionamento)*ritardo:end);

%Ottenimento del grafico della funzione di cross-correlazione.
figure('Name','Correlazione','NumberTitle','off');
plot((0:numel(correlazione_ricevuto)-1)/frequenza_campionamento,correlazione_ricevuto);
title('Correlazione Incrociata');
grid on;
xlabel('Tempo (s)');
ylabel('Ampiezza');

%Riproduco il segnale utile...
%sound(segnale_utile,frequenza_campionamento);


%% Demodulazione del segnale e filtraggio.
%In questa parte dello script ci si occupa di demodulare il segnale utile.
%Definisco un vettore delle frequenze, utile per rappresentare i vari
%grafici.
f = (0:(length(segnale_utile) - 1))' * (frequenza_campionamento / length(segnale_utile));
frequenza_modulazione = 8000;
segnale_ricevuto = ssbdemod(segnale_utile,frequenza_modulazione,frequenza_campionamento);

%Filtraggio del segnale, mediante la risposta impulsiva precedentemente
%definita.

segnale_filtrato = filter(risposta_impulsiva,1,segnale_ricevuto);

%Analisi spettrale del segnale ricevuto.
%Vengono rappresentati solo gli spettri di ampiezza.
%--------------------------------------------------------------------------
spettro_ricevuto = fft(segnale_ricevuto);
spettro_filtrato = fft(segnale_filtrato);

spettro_utile = fft(segnale_utile);

figure('Name','Spettro del segnale non demodulato','NumberTitle','off');
plot(f - frequenza_campionamento/2, fftshift(abs(spettro_utile)));
title("Spettro del segnale ricevuto (NON Demodulato)");
grid on;
xlabel("Frequenza (Hz)");
ylabel("Ampiezza");

figure('Name','Spettri del segnale demodulato','NumberTitle','off');
subplot(2,1,1);
plot(f - frequenza_campionamento/2, fftshift(abs(spettro_ricevuto)));
grid on;
title("Spettro del segnale Demodulato NON Filtrato");
xlabel('Frequenza (Hz)');
ylabel('Ampiezza');
subplot(2,1,2);
plot(f - frequenza_campionamento/2, fftshift(abs(spettro_filtrato )));
grid on;
title("Spettro del segnale Demodulato Filtrato");
xlabel('Frequenza (Hz)');
ylabel('Ampiezza');
%--------------------------------------------------------------------------
%Riproduco il segnale demodulato per verificare che l'informazione sia
%stata ricevuta correttamente.
sound(segnale_filtrato,frequenza_campionamento);
