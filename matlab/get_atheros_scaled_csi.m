function ret = get_atheros_scaled_csi(csi_st)
    % Pull out CSI
    csi = csi_st.csi;

    % Calculate the scale factor between normalized CSI and RSSI (mW)
    csi_sq = csi .* conj(csi);
    csi_pwr = sum(csi_sq(:));
    % Atheros card have rssi filed that is the total rss (correct??)
    %rssi_pwr = dbinv(get_total_rss(csi_st));
    rssi_pwr = dbinv(csi_st.rssi);
    %   Scale CSI -> Signal power : rssi_pwr / (mean of csi_pwr)
    scale = rssi_pwr / (csi_pwr / csi_st.num_tones);

    % Thermal noise might be undefined if the trace was
    % captured in monitor mode.
    % ... If so, set it to -92
    if (csi_st.noise_floor == 0)
        noise_db = -98;
    else
        noise_db = csi_st.noise_floor;
    end
    thermal_noise_pwr = dbinv(noise_db);
    
    % Quantization error: the coefficients in the matrices are
    % 8-bit signed numbers, max 127/-128 to min 0/1. Given that Intel
    % only uses a 6-bit ADC, I expect every entry to be off by about
    % +/- 1 (total across real & complex parts) per entry.
    %
    % The total power is then 1^2 = 1 per entry, and there are
    % Nrx*Ntx entries per carrier. We only want one carrier's worth of
    % error, since we only computed one carrier's worth of signal above.
    quant_error_pwr = scale * (csi_st.nr * csi_st.nc);

    % Total noise and error power
    total_noise_pwr = thermal_noise_pwr + quant_error_pwr;

    disp(dbinv(csi_st.rssi));
    disp(dbinv(81));
    return;
    % Ret now has units of sqrt(SNR) just like H in textbooks
    ret = csi * sqrt(scale / total_noise_pwr);
    if csi_st.nc == 2
        ret = ret * sqrt(2);
    elseif csi_st.nc == 3
        % Note: this should be sqrt(3)~ 4.77 dB. But, 4.5 dB is how
        % Intel (and some other chip makers) approximate a factor of 3
        %
        % You may need to change this if your card does the right thing.
        ret = ret * sqrt(dbinv(4.5));
    end
end
