% Αρχικοποίηση παραμέτρων
clc; clear; close all;

% Φόρτωση εικόνων
template = imread('NotreDame1.jpg'); % Η εικόνα-πρότυπο
image = imread('NotreDame2.jpg');      % Η εικόνα προς στοίχιση

% Μετατροπή εικόνων σε grayscale αν είναι έγχρωμες
if size(template, 3) == 3
    template = rgb2gray(template);
end
if size(image, 3) == 3
    image = rgb2gray(image);
end

% Κανονικοποίηση εικόνων
template = double(template) / 255;
image = double(image) / 255;

% Παράμετροι ευθυγράμμισης
levels = 3;               % Αριθμός επιπέδων πυραμίδας
noi = 10;                 % Μέγιστος αριθμός επαναλήψεων
transform = 'affine';     % Μετασχηματισμός (π.χ. affine, homography)
delta_p_init = [0 0 0; 0 0 0]; % Αρχική μετασχηματιστική μήτρα

% Κλήση της συνάρτησης ευθυγράμμισης
[results, results_lk, MSE, rho, MSELK] = ecc_lk_alignment(image, template, levels, noi, transform, delta_p_init);

% Εμφάνιση αποτελεσμάτων
disp('Αποτελέσματα Ευθυγράμμισης ECC:');
disp(results);
disp('Αποτελέσματα Ευθυγράμμισης LK:');
disp(results_lk);

% Γραφικές παραστάσεις MSE και ρ
figure;
subplot(1, 2, 1);
plot(MSE, '-o');
title('MSE (ECC)');
xlabel('Iteration');
ylabel('Mean Squared Error');

subplot(1, 2, 2);
plot(rho, '-o');
title('Correlation Coefficient (ρ - ECC)');
xlabel('Iteration');
ylabel('ρ');

% Απεικόνιση τελικών ευθυγραμμισμένων εικόνων
figure;
subplot(1, 2, 1);
imshow(uint8(results(levels, noi).image * 255));
title('Ευθυγραμμισμένη εικόνα (ECC)');

subplot(1, 2, 2);
imshow(uint8(results_lk(levels, noi).image * 255));
title('Ευθυγραμμισμένη εικόνα (LK)');
