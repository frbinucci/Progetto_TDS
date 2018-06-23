function [ risposta ] = generaRisposta( fpass,fstop,Apass,Astop,frequenza_campionamento )
%Funzione "generaRisposta()", necessaria a generare la risposta impulsiva
%di un filtro.
%   Questa funzione consente di generare la risposta impulsiva di uno
%   specifico filtro avente le caratteristiche passate come parametri alla
%   funzione. Viene utilizzato l'algoritmo di Parks-McClellan, nativamente
%   implementato da Matlab.
%   In particolare:
%   fpass => Rappresenta il limite della banda passante.
%   fstop => Rappresenta il limite della banda di transizione.
%   Apass => Rappresenta il massimo ripple in banda passante.
%   Astop => Rappresenta il massimo ripple in banda di transizione.

[N, Fo, Mo, W] = firpmord([fpass fstop], ... % estremi della banda di transizione
                            [1 0], ... % ampiezze desiderate nella banda passante e tagliante
                            [(10^(Apass/20) - 1) 10^(-Astop/20)], ... % ripple e attenuazione IN LINEARE
                            frequenza_campionamento); % la frequenza di campionamento
N = 2 * ceil(N/2) + 2;
risposta = firpm(N, Fo, Mo, W);


end

