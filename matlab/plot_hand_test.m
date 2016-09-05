function x = plot_hand_test(rx, tx)
    x = true;
    [mean1, variance1, index1] = test_fft_mean('sample/hand_test_100/hand_test_without_hand_100', 30, rx, tx);
    disp('lido 1');
    [mean2, variance2, index2] = test_fft_mean('sample/hand_test_100/hand_test_with_hand_100', 30, rx, tx);
    disp('lido 2');
    
    Fs = 100;
    T = 1/Fs;
    L = 30;
    t = (0:L-1)*T;
    
    P2_abs_1 = abs(mean1/L);
    P2_real_1 = real(mean1);
    P2_angle_1 = angle(mean1);
    
    P1_abs_1 = P2_abs_1([1:L/2+1],:);
    P1_abs_1([2:end-1],:) = 2*P1_abs_1([2:end-1],:);
    P1_real_1 = P2_real_1([1:L/2+1],:);
    P1_real_1([2:end-1],:) = 2*P1_real_1([2:end-1],:);
    P1_angle_1 = P2_angle_1([1:L/2+1],:);
    P1_angle_1([2:end-1],:) = 2*P1_angle_1([2:end-1],:);
    
    f = Fs*(0:(L/2))/L;
    
    subplot(3,2,1);
    plot(f,P1_abs_1);
    title('ABS: Sem mão');
    xlabel('f (Hz)');
    ylabel('|P1(f)|');
    ylim([0 500]);
    
    subplot(3,2,3);
    plot(f,P1_real_1);
    title('REAL: Sem mão');
    xlabel('f (Hz)');
    ylabel('|P1(f)|');
    ylim([-15000 15000]);
    
    subplot(3,2,5);
    plot(f,P1_angle_1);
    title('ANGLE: Sem mão');
    xlabel('f (Hz)');
    ylabel('|P1(f)|');
    ylim([-10 10]);
    
    % with hand    
    P2_abs_2 = abs(mean2/L);
    P2_real_2 = real(mean2);
    P2_angle_2 = angle(mean2);
    
    P1_abs_2 = P2_abs_2([1:L/2+1],:);
    P1_abs_2([2:end-1],:) = 2*P1_abs_2([2:end-1],:);
    P1_real_2 = P2_real_2([1:L/2+1],:);
    P1_real_2([2:end-1],:) = 2*P1_real_2([2:end-1],:);
    P1_angle_2 = P2_angle_2([1:L/2+1],:);
    P1_angle_2([2:end-1],:) = 2*P1_angle_2([2:end-1],:);
    
    f = Fs*(0:(L/2))/L;
    
    subplot(3,2,2);
    plot(f,P1_abs_2);
    title('ABS: Com mão');
    xlabel('f (Hz)');
    ylabel('|P1(f)|');
    ylim([0 500]);
    
    subplot(3,2,4);
    plot(f,P1_real_2);
    title('REAL: Com mão');
    xlabel('f (Hz)');
    ylabel('|P1(f)|');
    ylim([-15000 15000]);
    
    subplot(3,2,6);
    plot(f,P1_angle_2);
    title('ANGLE: Com mão');
    xlabel('f (Hz)');
    ylabel('|P1(f)|');
    ylim([-10 10]);
end
