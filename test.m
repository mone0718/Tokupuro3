subject_name = "Egashira";

fileName = "filtered_result.txt";
fileID = fopen(fileName, 'w');

fprintf(fileID, '%s CMCmax: %0.4f, PF: %2.0f, CMCarea: %0.4f\n', subject_name, CMCmax, PF, CMCarea);
%fprintf(fileID, 'PF: %2.0f\n', PF);
