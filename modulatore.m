%% Area di inizializzazione
clearvars;
close all;
%% Area di presentazione.
%In questa sezione vengono mostrate le istruzioni utili per il
%funzionamento dello script.
disp("***Istruzioni per l'utilizzo dello script***");
disp("Per il corretto funzionamento dello script di consiglia di: ");
disp("1)Registrare il messaggio vocale che si intende trasmettere");
disp("2)Prelevare il file .wav, presente nella cartella di esecuzione dello script");
disp("3)Riprodurre il file mediante un dispositivo (es. smartphone) all'atto di ricezione");
disp("Nota: l'acquisizione del segnale dura 10 secondi.");
disp("Premere invio per procedere con la registrazione...");
pause();
%% Acquisizione del segnale da trasmettere.

%Il segnale in ricezione viene acquisito tramite microfono.
%Definizione del tempo di registrazione (10 secondi).
tempo_acquisizione = 10;
%Definizione della frequenza di campionamento necessaria.
frequenza_campionamento = 50000;
%Definizione dell'oggetto necessario alla registrazione dell'audio.
rec = audiorecorder(frequenza_campionamento,16,1);

%Acquizione dell'audio tramite il microfono del computer.
record(rec, tempo_acquisizione); 
pause(tempo_acquisizione+1); 
stop(rec);

%Ottenimento del segnale informativo, contenente l'informazione che deve
%essere trasmessa.
segnale_acquisito = getaudiodata(rec);

%% Filtraggio del segnale.
%Il segnale non viene trasmesso sfruttando le onde radio (come di norma
%avviene nella modulazione di ampiezza), ma viene trasmesso tramite un
%altoparlante. Prima di modulare il segnale, esso viene filtrato
%passabasso, in modo da conservare le componenti fino a 4KHz.

%Definisco i parametri del filtro.
fpass = 4000; %%Limite banda passante.
fstop = 4500; %%Limite banda di transisione.
Apass = 1; %%Ripple in banda passante. (dB).
Astop = 45; %%Ripple in banda di transizione (dB).

%Visto che il filtraggio di un segnale è una problematica ricorrente, si è
%deciso di automatizzare la generazione della risposta impulsiva del filtro
%mediante la definizione di un'apposita funzione, caricata in uno script
%esterno.
risposta_impulsiva = generaRisposta(fpass,fstop,Apass,Astop,frequenza_campionamento);

%Rappresento graficamente la funzione di trasferimento del filtro
%passa-basso appena creato.
funzione_trasferimento = fft(risposta_impulsiva,2^11);
asse_frequenze = (0:(length(funzione_trasferimento) - 1))' * (frequenza_campionamento / length(funzione_trasferimento));
figure('Name','Funzione di trasferimento del filtro','NumberTitle','off');
subplot(2,1,1);
plot(asse_frequenze - frequenza_campionamento/2, fftshift(abs(funzione_trasferimento)));
grid on;
xlabel('Frequenza (Hz)');
ylabel('Ampiezza');
subplot(2,1,2);
plot(asse_frequenze - frequenza_campionamento/2, fftshift(phase(funzione_trasferimento)));
grid on;
xlabel('Frequenza (Hz)');
ylabel('Fase (°)');

%--------------------------------------------------------------------------
%Filtro il segnale acquisito mediante la risposta impulsiva precedentemente
%definita.
segnale_informativo = filter(risposta_impulsiva,1, segnale_acquisito);

%Riporto l'asse delle frequenze dalla frequenza normalizzata alla frequenza
%in Hz. (Tale operazione mi serve a plottare gli spettri di ampiezza).
f = (0:(length(segnale_acquisito) - 1))' * (frequenza_campionamento / length(segnale_acquisito));

%Calcolo la DFT dei due segnali acquisiti mediante la funzione "fft()",
%messa a disposizione da Matlab.
spettro_segnale_acquisito = fft(segnale_acquisito);
spettro_segnale_informativo = fft(segnale_informativo);

%Ottenimento degli spettri di ampiezza del segnale acquisito e di quello
%filtrato.
%--------------------------------------------------------------------------
figure('Name','Spettri Segnali Acquisiti','NumberTitle','off');
subplot(2,1,1);
plot(f - frequenza_campionamento/2, fftshift(abs(spettro_segnale_acquisito)));
title('Spettro di ampiezza del segnale NON Filtrato');
grid on;
xlabel('Frequenza (Hz)');
ylabel('Ampiezza');
subplot(2,1,2);
plot(f-frequenza_campionamento/2,fftshift(abs(spettro_segnale_informativo)));
title('Spettro di ampiezza del segnale Filtrato');
grid on;
xlabel('Frequenza (Hz)');
ylabel('Ampiezza');
%--------------------------------------------------------------------------

%% Modulazione del segnale
%In questa parte dello script ci si occupa di modulare il segnale in
%ampiezza, attorno ad una frequenza di 8000Khz. Il valore della frequenza è
%scelto in maniera tale che il segnale possa essere riprodotto
%dall'altoparlante di un telefono. 
%Si è deciso di impiegare la tecnica di modulazione SSB (Single Side Band),
%una tecnica di modulazione di ampiezza che consente di trasmettere il
%segnale sopprimendo metà della banda.

frequenza_portante = 8000;

%La modulazione avviene mediante la funzione "SSB", messa a disposizione da
%Matlab.
segnale_modulato = ssbmod(segnale_informativo,frequenza_portante,frequenza_campionamento);

%Analisi spettrale del segnale Modulato.
%--------------------------------------------------------------------------
%Calcolo della DFT del segnale modulato.
spettro_modulato = fft(segnale_modulato);
%Rappresentazione grafica dello spettro delle ampiezze.
figure('Name','Spettro del segnale Modulato','NumberTitle','off');
plot(f - frequenza_campionamento/2, fftshift(abs(spettro_modulato)));
grid on;
xlabel('Frequenza (Hz)');
ylabel('Ampiezza');

%% Aggiunta della parte necessaria alla correlazione in ricezione.
%In questa parte dello script ci ci occupa di inserire nel segnale una
%sequenza di Barker nota anche al ricevitore. In questo modo è possibile
%sincronizzare il ricevitore in ricezione, in modo che possa demodulare
%solo la parte di segnale "Utile".

H = comm.BarkerCode('SamplesPerFrame',10000);

sequenza_nota = H();

%Concateno il segnale con la sequenza nota, in modo tale che il ricevitore
%possa capire da dove inizia la parte di segnale modulato.
segnale_trasmesso = [sequenza_nota;segnale_modulato];

%Esportazione del segnale modulato con la relativa sequenza di
%sincronizzazione su un file ".wav". In questo modo è possibile riprodurre
%il file mediante un dispositivo per simulare la trasmissione radio.
audiowrite('modulato.wav',segnale_trasmesso,frequenza_campionamento);






