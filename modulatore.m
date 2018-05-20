%% Sezione di inizializzazione.

clearvars;
close all;

%% Debug area
type = input('Acquisire audio? (1)');

%% Questa area serve ad acquisire un audio tramite il microfono.

%Definizione delle variabili necessarie.
if (type == 1)
    %Definisco una frequenza di campionamento, necessaria all'acquisizione del
    %segnale.
    frequenza_campionamento = 50000;
    %Definisco un tempo di registrazione del segnale.
    tempo_acquisizione = 5;
    
    %Definizione dell'oggetto che consente di rappresentare il registratore del
    %sistema, indispensabile per l'acquisizione del segnale mediante il
    %microfono.
    rec = audiorecorder(frequenza_campionamento,16,1);
    %Acquisizione del segnale tramite microfono.
    record(rec, tempo_acquisizione); 
    pause(tempo_acquisizione+1); 
    stop(rec);
    %Ottengo il segnale_modulantetore dei campioni acquisiti.
    segnale_modulante = getaudiodata(rec);
else
    [segnale_modulante, frequenza_campionamento] = audioread('violino.wav');   
end
sound(segnale_modulante,frequenza_campionamento);

%% Filtraggio del segnale.
%In questa sezione di codice ci si occupa di filtrare il segnale acquisito,
%in modo da far sì che contenga componenti frequenziali solo nell'ordine
%dei 4KHz.

%Definisco i parametri del filtro.
fpass = 3500; %%Limite banda passante.
fstop = 3900; %%Limite banda di transisione.
Apass = 1; %%Ripple in banda passante. (dB).
Astop = 45; %%Ripple in banda di transizione (dB).

[N, Fo, Mo, W] = firpmord([fpass fstop], ... % estremi della banda di transizione
                            [1 0], ... % ampiezze desiderate nella banda passante e tagliante
                            [(10^(Apass/20) - 1) 10^(-Astop/20)], ... % ripple e attenuazione IN LINEARE
                            frequenza_campionamento); % la frequenza di campionamento

%??????????????????????????????????????????????????????????????????????????
% forziamo un ordine pari, cioè un numero di tappi dispari (per sicurezza)
N = 2 * ceil(N/2) + 2; % più un paio di tappi per una migliore aderenza alle specifiche

risposta_impulsiva = firpm(N, Fo, Mo, W);
funzione_trasferimento = fft(risposta_impulsiva);
asse_frequenze = (0:(length(risposta_impulsiva) - 1))' * (frequenza_campionamento / length(risposta_impulsiva));

figure('Name','Filtro','NumberTitle','off');
subplot(2,1,1);
plot(0:N,risposta_impulsiva);
grid on;
xlabel("Tempo");
ylabel("Ampiezza");
subplot(2,1,2);
plot(asse_frequenze-frequenza_campionamento/2,20*log10(abs(funzione_trasferimento)));
grid on;
xlabel("Frequenza (HZ)");
ylabel("Ampiezza");

segnale_modulante = filter(risposta_impulsiva, 1, segnale_modulante);

%sound(segnale_modulante,frequenza_campionamento);


%% Modulazione del segnale
%In questa sezione di codice si procede alla modulazione in ampiezza del
%segnale filtrato.

%Stima spettrale del segnale, tramite l'utilizzo della funzione "fft()",
%necessaria al calcolo della DFT.
X1 = fft(segnale_modulante);
%Porto l'asse delle frequenze in Hz.
f = (0:(length(X1) - 1))' * (frequenza_campionamento / length(X1));

%Ottengo i grafici dello spettro di ampiezza e dell'andamento temporale del
%segnale acquisito (segnale modulante).
figure('Name','Segnale Modulante','NumberTitle','off');
subplot(2,1,1);
plot(f - frequenza_campionamento/2, fftshift(abs(X1)));
grid on;
xlabel('Frequenza (Hz)');
ylabel('Ampiezza');
subplot(2,1,2);
plot((0:numel(segnale_modulante)-1)/frequenza_campionamento,segnale_modulante);
grid on;
xlabel('Tempo (s)');
ylabel('Ampiezza');

%Riproduco il segnale per constare l'effettiva registrazione.
%sound(segnale_modulante,frequenza_campionamento);

%Definisco la frequenza del segnale portante. Il processo di modulazione
%traslerà lo spettro del segnale modulante (segnale acquisito tramite
%microfono) attorno alla frequenza del segnale portante, in questo caso,
%12KHz.
frequenza_modulazione = 8000;

%Modulazione del segnale mediante la funzione "ammod()", messa a
%disposizione da Matlab. 
%La funzione richiede in input 3 parametri:
%1)Il segnale da modulare.
%2)La frequenza della portante.
%3)La frequenza di campionamento del segnale modulate.
segnale_modulato = ammod(segnale_modulante,frequenza_modulazione,frequenza_campionamento);

%Stima dello spettro del segnale modulato tramite l'algoritmo di DFT.
spettro_segnale_modulato = fft(segnale_modulato);

%Ottengo i grafici dello spettro di ampiezza e dell'andamento temporale del
%segnale acquisito (segnale modulante).
figure('Name','Segnale Modulato','Numbertitle','off');
subplot(2,1,1);
plot((0:numel(segnale_modulato)-1)/frequenza_campionamento,segnale_modulato);
grid on;
xlabel('Tempo (s)');
ylabel('Ampiezza');
subplot(2,1,2);
plot(f - frequenza_campionamento/2, fftshift(abs(spettro_segnale_modulato)));
grid on;
xlabel('Frequenza (Hz)');
ylabel('Ampiezza');

%Riproduco il segnale modulato.
%sound(segnale_modulato,frequenza_campionamento);

%% Sezione di esportazione

audiowrite('modulato.wav',segnale_modulato,frequenza_campionamento);










