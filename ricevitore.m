%% Area di inizializzazione
clearvars;

close all;

%% Acquisizione del segnale
%Per l'acquisizione, al momento, si registra il segnale... (da
%migliorare....).

%Si assume che il segnale in ricezione abbia una banda "centrata" sulla
%frequenza di 8KHz.
frequenza_sintonizzazione_1 = 1000;
frequenza_sintonizzazione_2 = 4000;
%Definisco la frequenza di campionamento, necessaria all'acquisizione del
%segnale.
frequenza_campionamento = 50000;

%Definisco un tempo di registrazione del segnale.
tempo_acquisizione = 7;
%L'acquizione del segnale avviene in modo del tutto analogo rispetto allo
%script di trasmissione.
%Definizione dell'oggetto necessario.
rec = audiorecorder(frequenza_campionamento,16,1);  
%Acquisizione del segnale tramite microfono.  
record(rec, tempo_acquisizione);   
pause(tempo_acquisizione+1);    
stop(rec);

segnale_ricevuto = getaudiodata(rec);

%In fase di testing provo ad acquisire il segnale mediante un apposito file
%audio.
%[segnale_ricevuto,frequenza_campionamento] = audioread('modulato.wav');

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

%Demodulazione dei due segnali mediante la funzione "amdemod".
primo_segnale_demodulato = amdemod(segnale_ricevuto,frequenza_sintonizzazione_1,frequenza_campionamento);
secondo_segnale_demodulato = amdemod(segnale_ricevuto,frequenza_sintonizzazione_2,frequenza_campionamento);

%Ottenimento dello spettro dei due segnali.
primo_spettro_demodulato = fft(primo_segnale_demodulato);
secondo_spettro_demodulato = fft(secondo_segnale_demodulato);

%Restituzione grafica dello spettro dei due segnali.
figure('Name','Segnale demodulato','Numbertitle','off');
subplot(2,1,1);
plot(f - frequenza_campionamento/2, fftshift(abs(primo_spettro_demodulato)));
title('Spettro di ampiezza del primo segnale demodulato');
xlabel('Frequenza (Hz)');
ylabel('Ampiezza');
grid on;
subplot(2,1,2);
plot(f - frequenza_campionamento/2, fftshift(abs(secondo_spettro_demodulato)));
title('Spettro di ampiezza del secondo segnale demodulato');
grid on;
xlabel('Frequenza(Hz)');
ylabel('Ampiezza');

%% Riproduzione del segnale demodulato.
sound(primo_segnale_demodulato,frequenza_campionamento);
pause(6);
%sound(secondo_segnale_demodulato,frequenza_campionamento);

