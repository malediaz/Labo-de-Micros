function main():

    clear all
    clc
    X=4;

    V = zeros(X,1024);
    V2 = zeros(X,1024);
    N=1024;
    Fs = 500;
    time = (0:N-1)./Fs;
    s = Serial_Init(N);
    pause(1)
    buffer_index = zeros(X,1);
    tic

    for n = 1:X
        [V(n,:),buffer_index(n)] = Serial_READ(s,N);
        pause(0.200)
    end
    toc

    for n =1:X
        V2(n,:) = V(n,[buffer_index(n)+1:end 1:buffer_index(n)]);
    end

    for n = 1:X
        figure(n)
        plot(time,V2(n,:),'-o')
        ax = gca;
        %ax.XAxis.Exponent = -3;
        axis([0 1023/Fs 0 7])
        grid on
        xlabel('Time (ms)')
        ylabel('Amplitude')
    end

    Serial_close(s)

end