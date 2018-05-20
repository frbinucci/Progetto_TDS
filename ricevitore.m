%% Area di inizializzazione
clearvars;

close all;

%% Acquisizione del segnale
%Per l'acquisizione, al momento, si registra il segnale... (da
%migliorare....).

%Si assume che il segnale in ricezione abbia una banda "centrata" sulla
%frequenzaa di 8KHz.
frequenza_sintonizzazione = 8000;
%Definisco la frequenza di campionamento, necessaria all'acquisizione del
%segnale.
frequenza_campionamento = 50000;

%Definisco un tempo di registrazione del segnale.
tempo_acquisizione = 20;
%L'acquizione del segnale avviene in modo del tutto analogo rispetto allo
%script di trasmissione.
%Definizione dell'oggetto necessario.
rec = audiorecorder(frequenza_campionamento,16,1);  
%Acquisizione del segnale tramite microfono.  
record(rec, tempo_acquisizione);   
pause(tempo_acquisizione+1);    
stop(rec);

segnale_ricevuto = getaudiodata(rec);

%% Analisi spettrale del segnale ricevuto.

spettro = fft(segnale_ricevuto);
%Porto l'asse delle frequenze in Hz.
f = (0:(length(spettro) - 1))' * (frequenza_campionamento / length(spettro));

%Ottengo i grafici dello spettro di ampiezza e dell'andamento temporale del
%segnale acquisito, modulato in ampiezza.
figure('Name','Segnale Ricevuto','NumberTitle','off');
subplot(2,1,1);
plot(f - frequenza_campionamento/2, fftshift(abs(spettro)));
grid on;
xlabel('Frequenza (Hz)');
ylabel('Ampiezza');
subplot(2,1,2);
plot((0:numel(segnale_ricevuto)-1)/frequenza_campionamento,segnale_ricevuto);
grid on;
xlabel('Tempo (s)');
ylabel('Ampiezza');

%% Demodulazione del segnale e analisi spettrale del segnale de-modulato.

segnale_demodulato = amdemod(segnale_ricevuto,frequenza_sintonizzazione,frequenza_campionamento);
spettro_demodulato = fft(segnale_demodulato);

figure('Name','Segnale demodulato','Numbertitle','off');
subplot(2,1,1);
plot(f - frequenza_campionamento/2, fftshift(abs(spettro_demodulato)));
xlabel('Frequenza (Hz)');
ylabel('Ampiezza');
grid on;
subplot(2,1,2);
plot((0:numel(segnale_demodulato)-1)/frequenza_campionamento,segnale_demodulato);
grid on;
xlabel('Tempo (s)');
ylabel('Ampiezza');

%% Riproduzione del segnale demodulato.
sound(segnale_demodulato,frequenza_campionamento);
