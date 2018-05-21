%% Sezione di inizializzazione.

clearvars;
close all;

%% Debug area
%Questa sezione serve a stabilire se si vuole acquisire il segnale tramite
%il microfono, oppure utilizzare un file audio già definito (solo a scopo
%di test).
type = input('Acquisire audio? (1)');

%% Questa area serve ad acquisire un audio tramite il microfono.

%Se è stato digitato "1", vengono eseguite le procedure necessarie ad
%acquisire un file audio tramite microfono.
if (type == 1)
    %Definisco una frequenza di campionamento, necessaria all'acquisizione del
    %segnale.
    frequenza_campionamento = 50000;
    %Definisco un tempo di registrazione del segnale.
    tempo_acquisizione = 10;
    %Definizione dell'oggetto che consente di rappresentare il registratore del
    %sistema, indispensabile per l'acquisizione del segnale mediante il
    %microfono.
    rec = audiorecorder(frequenza_campionamento,16,1);
    
    %Acquisizione del segnale tramite microfono.
    record(rec, tempo_acquisizione); 
    pause(tempo_acquisizione+1); 
    stop(rec);
    %Ottengo il segnale modulante.
    segnale_modulante = getaudiodata(rec);
    half = ceil(length(segnale_modulante)/2);
    
    %In questa nuova versione dello script, il file acquisito tramite il
    %microfono viene suddiviso in due parti. L'idea fondamentale è quella
    %di modulare ciascuna parte in ampiezza, su una frequenza differente,
    %per poi sovrapporre i due segnali in un segnale unico.
    parte_1 = segnale_modulante(1:half);
    parte_2 = segnale_modulante(half+1:end);
else
    [segnale_modulante, frequenza_campionamento] = audioread('violino.wav');   
end

%% Costruzione del filtro passa-basso.
%In questa sezione di codice ci si occupa di filtrare il segnale acquisito,
%in modo da far sì che contenga componenti frequenziali solo nell'ordine
%dei 2KHz.

%Vengono filtrati i due segnali passa-basso, in modo da far sì che il loro spettri
%modulati risultino ben separati.

%Definisco i parametri del filtro.
fpass = 2500; %%Limite banda passante.
fstop = 2900; %%Limite banda di transisione.
Apass = 1; %%Ripple in banda passante. (dB).
Astop = 45; %%Ripple in banda di transizione (dB).

[N, Fo, Mo, W] = firpmord([fpass fstop], ... % estremi della banda di transizione
                            [1 0], ... % ampiezze desiderate nella banda passante e tagliante
                            [(10^(Apass/20) - 1) 10^(-Astop/20)], ... % ripple e attenuazione IN LINEARE
                            frequenza_campionamento); % la frequenza di campionamento


N = 2 * ceil(N/2) + 2;

risposta_impulsiva = firpm(N, Fo, Mo, W);
%% Sezione dedicata al plot della risposta impulsiva del filtro e della relativa Funzione di Trasferimento (Opzionale).
%funzione_trasferimento = fft(risposta_impulsiva);
%asse_frequenze = (0:(length(risposta_impulsiva) - 1))' * (frequenza_campionamento / length(risposta_impulsiva));

%figure('Name','Filtro','NumberTitle','off');
%subplot(2,1,1);
%plot(0:N,risposta_impulsiva);
%grid on;
%xlabel("Tempo");
%ylabel("Ampiezza");
%subplot(2,1,2);
%plot(asse_frequenze-frequenza_campionamento/2,20*log10(abs(funzione_trasferimento)));
%grid on;
%xlabel("Frequenza (HZ)");
%ylabel("Ampiezza");

%% Filtraggio dei due segnali.
parte_1 = filter(risposta_impulsiva,1, parte_1);
parte_2 = filter(risposta_impulsiva,1,parte_2);

%sound(parte_1,frequenza_campionamento);
%pause(6);
%sound(parte_2,frequenza_campionamento);

%% Analisi Spettrale dei segnali filtrati.

%In questa sezione di codice si procede ad una stima spettrale dei due
%segnali filtrati, in modo da verificare l'effettiva separazione
%frequenziale dei due spettri.

%Stima spettrale di ciascuno dei due segnali, mediante l'utilizzo della
%funzione Matlab "fft()", necessario al calcolo della DFT di un segnale.
spettro_primo_segnale_modulante = fft(parte_1);
spettro_secondo_segnale_modulante = fft(parte_2);

%Porto l'asse delle frequenze in Hz.
f = (0:(length(parte_1) - 1))' * (frequenza_campionamento / length(parte_1));

%Ottengo i grafici degli spettri delle ampiezze dei due segnali (parte_1 e
%parte_2).
%--------------------------------------------------------------------------
%Parte_1
figure('Name','Spettri Segnali Acquisiti','NumberTitle','off');
subplot(2,1,1);
plot(f - frequenza_campionamento/2, fftshift(abs(spettro_primo_segnale_modulante)));
title('Spettro del primo segnale modulante');
grid on;
xlabel('Frequenza (Hz)');
ylabel('Ampiezza');
%Parte_2
subplot(2,1,2);
plot(f-frequenza_campionamento/2,fftshift(abs(spettro_secondo_segnale_modulante)));
title('Spettro del secondo segnale modulante');
grid on;
xlabel('Frequenza (Hz)');
ylabel('Ampiezza');
%--------------------------------------------------------------------------

%Ottengo i grafici degli spettri delle ampiezze dei due segnali (parte_1 e
%parte_2).
%--------------------------------------------------------------------------
%Parte_1
figure('Name','Andamenti Temporali Segnali Acquisiti','NumberTitle','off');
subplot(2,1,1);
plot((0:numel(parte_1)-1)/frequenza_campionamento,parte_1);
grid on;
title('Andamento temporale del primo segnale modulante');
xlabel('Tempo (s)');
ylabel('Ampiezza');
%Parte_2
subplot(2,1,2);
plot((0:numel(spettro_secondo_segnale_modulante)-1)/frequenza_campionamento,parte_2);
grid on;
xlabel('Tempo (s)');
ylabel('Ampiezza');
title('Andamento temporale del secondo segnale modulante');
%--------------------------------------------------------------------------
%% Modulazione del segnale.
%Definisco la frequenza del segnale portante. Il processo di modulazione
%traslerà lo spettro del segnale modulante (segnale acquisito tramite
%microfono) attorno alla frequenza del segnale portante.

%Per sopperire alle difficoltà nella riproduzione di segnali a frequenza
%troppo elevata, al momento, si è pensato di modulare i due segnali attorno
%alle frequenze di 10KHz e 4KHz (funzionalità da migliorare...).
frequenza_modulazione_parte1 = 10000;
frequenza_modulazione_parte2 = 4000;

%Modulazione del segnale mediante la funzione "ammod()", messa a
%disposizione da Matlab. 
%La funzione richiede in input 3 parametri:
%1)Il segnale da modulare.
%2)La frequenza della portante.
%3)La frequenza di campionamento del segnale modulate.
primo_segnale_modulato = ammod(parte_1,frequenza_modulazione_parte1,frequenza_campionamento);
secondo_segnale_modulato = ammod(parte_2,frequenza_modulazione_parte2,frequenza_campionamento);

%Una volta modulati i due segnali, vengono dovrapposti, e viene così
%generato un terzo segnale chiamato "sovrapposizione_modulata".
sovrapposizione_modulata = primo_segnale_modulato + secondo_segnale_modulato;

%Ottenimento dello spettro dei tre segnali modulati, mediante l'algoritmo
%di FFT.
spettro_primo_segnale_modulato = fft(primo_segnale_modulato);
spettro_secondo_segnale_modulato = fft(secondo_segnale_modulato);
spettro_sovrapposizione_modulata = fft(sovrapposizione_modulata);

%Ottenimento dei grafici relativi ai tre spettri delle ampiezze.
%--------------------------------------------------------------------------
figure('Name','Spettri Segnali Modulati','NumberTitle','off');
subplot(2,1,1);
plot(f - frequenza_campionamento/2, fftshift(abs(spettro_primo_segnale_modulato)));
title('Spettro del primo segnale modulanto (10KHz)');
grid on;
xlabel('Frequenza (Hz)');
ylabel('Ampiezza');

subplot(2,1,2);
plot(f-frequenza_campionamento/2,fftshift(abs(spettro_secondo_segnale_modulato)));
grid on;
title('Spettro del secondo segnale modulato(4KHz)');
xlabel('Frequenza (Hz)');
ylabel('Ampiezza');

figure('Name','Spettro dei segnali sovrapposti','NumberTitle','off');
plot(f - frequenza_campionamento/2, fftshift(abs(spettro_sovrapposizione_modulata)));
title('Spettro del segnale costituito dalla sovrapposizione dei due segnali modulati');
grid on;
xlabel('Frequenza (Hz)');
ylabel('Ampiezza');
%--------------------------------------------------------------------------
%% Sezione di esportazione
%Al fine di evitare le problematiche dovute all'acquisizione dell'audio
%tramite microfono, si è pensato di esportare il segnale modulato
%all'interno di un file...
audiowrite('modulato.wav',sovrapposizione_modulata,frequenza_campionamento);










