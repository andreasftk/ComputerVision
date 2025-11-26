clc; clear; close all;

% 1. Δημιουργία ημιτονοειδούς σήματος με θόρυβο
N = 100; % Μήκος σήματος
signal = sin(2 * pi * (1:N) / 20) + 0.2 * randn(1, N); % Ημίτονο με θόρυβο

% 2. Ορισμός του Γκαουσιανού φίλτρου (h)
h = (1/16) * [1, 4, 6, 4, 1];

% 3. Δημιουργία Γκαουσιανής Πυραμίδας
L = 4; % Αριθμός επιπέδων
gaussian_pyr = cell(1, L);
gaussian_pyr{1} = signal;

for i = 2:L
    smoothed = conv(gaussian_pyr{i-1}, h, 'same'); % Φιλτράρισμα με Γκαουσιανό πυρήνα
    gaussian_pyr{i} = smoothed(1:2:end); % Υποδειγματοληψία (Downsampling)
end

% 4. Μετατροπή Γκαουσιανής σε Λαπλασιανή Πυραμίδα
laplacian_pyr = cell(1, L);

for i = 1:L-1
    expanded = upsampleAndFilter(gaussian_pyr{i+1}, h); % Upsampling & Φιλτράρισμα

    % **Προσαρμογή μεγέθους** ώστε να ταιριάζει με το gaussian_pyr{i}
    if length(expanded) > length(gaussian_pyr{i})
        expanded = expanded(1:length(gaussian_pyr{i}));
    elseif length(expanded) < length(gaussian_pyr{i})
        expanded = [expanded, zeros(1, length(gaussian_pyr{i}) - length(expanded))];
    end

    laplacian_pyr{i} = gaussian_pyr{i} - expanded; % Υπολογισμός Λαπλασιανής
end
laplacian_pyr{L} = gaussian_pyr{L}; % Το τελευταίο επίπεδο παραμένει το ίδιο

% 5. Ανακατασκευή της Γκαουσιανής Πυραμίδας από τη Λαπλασιανή
reconstructed_gaussian = cell(1, L);
reconstructed_gaussian{L} = laplacian_pyr{L};

for i = L-1:-1:1
    expanded = upsampleAndFilter(reconstructed_gaussian{i+1}, h);

    % **Προσαρμογή μεγέθους** ώστε να ταιριάζει με το laplacian_pyr{i}
    if length(expanded) > length(laplacian_pyr{i})
        expanded = expanded(1:length(laplacian_pyr{i}));
    elseif length(expanded) < length(laplacian_pyr{i})
        expanded = [expanded, zeros(1, length(laplacian_pyr{i}) - length(expanded))];
    end

    reconstructed_gaussian{i} = laplacian_pyr{i} + expanded;
end

% 6. Σύγκριση του αρχικού σήματος με το ανακατασκευασμένο
figure;
subplot(3,1,1);
plot(signal, 'k', 'LineWidth', 2); hold on;
plot(reconstructed_gaussian{1}, 'r--', 'LineWidth', 2);
legend('Αρχικό Σήμα', 'Ανακατασκευασμένο Σήμα');
title('Σύγκριση Αρχικού και Ανακατασκευασμένου Σήματος');
xlabel('Δείκτες');
ylabel('Τιμή');
grid on;

% Οπτικοποίηση των πυραμίδων
subplot(3,1,2);
for i = 1:L
    plot(gaussian_pyr{i}, 'LineWidth', 2); hold on;
end
title('Γκαουσιανή Πυραμίδα');
xlabel('Δείκτες');
ylabel('Τιμή');
grid on;

subplot(3,1,3);
for i = 1:L-1
    plot(laplacian_pyr{i}, 'LineWidth', 2); hold on;
end
title('Λαπλασιανή Πυραμίδα');
xlabel('Δείκτες');
ylabel('Τιμή');
grid on;

% 7. Συνάρτηση για Up-Sampling και Φιλτράρισμα
function upsampled = upsampleAndFilter(signal, h)
    upsampled = zeros(1, 2 * length(signal)); % Εισαγωγή μηδενικών
    upsampled(1:2:end) = signal; % Upsampling
    upsampled = conv(upsampled, h, 'same'); % Φιλτράρισμα με Γκαουσιανό
end
