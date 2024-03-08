import pandas
import csv
import re

def extract_digit_sequences(s):
    #find all sequences of digits
    digit_sequences = re.findall(r'\d+', s)
    
    #check if '-' is present and ensure single numbers are duplicated
    if '-' in s and len(digit_sequences) == 2:
        #if there are two numbers separated by '-', just convert them to integers
        return [int(num) for num in digit_sequences]
    else:
        #if there's only one number
        return ['0', int(digit_sequences[0])]
    

if __name__ == '__main__':

    #read xlsx file into pandas dataframe
    df = pandas.read_excel('srcsc-2024-lumaria-economic-data.xlsx', sheet_name='EconomicData', header=11)
    #export pandas dataframe to csv file
    df.to_csv('Economy.csv', index=False)

    with open('Economy.csv', mode='r') as csv_file:
        economy = csv.reader(csv_file)
        data = [row for row in economy]
        col_names = data[0]
        del col_names[5:]
        table = data[1:]
        for j in range(len(table)):
            del table[j][5]
            for i in range(1, 5):
                table[j][i] = float(table[j][i]) * 100



    with open('economy_cleaned.csv', mode='w', newline='') as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(col_names)

        for row in table:
            writer.writerow(row)