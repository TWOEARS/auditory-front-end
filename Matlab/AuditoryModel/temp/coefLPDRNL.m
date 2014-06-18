% rev Morten Løve Jepsen, 2.nov 2005
function [b,a]=coefLPDRNL(fc,fs);

    theta = pi*fc/fs;
    
    C = 1/(1+sqrt(2)*cot(theta)+(cot(theta))^2);
    D = 2*C*(1-(cot(theta))^2);
    E = C*(1-sqrt(2)*cot(theta)+(cot(theta))^2);

    b = [C, 2*C, C]; a = [1, D, E];
    
 




