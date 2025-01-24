#Python code to chunk the literary texts into six-sentence passages

import pandas as pd
import spacy
import os

# Load the English model from spaCy
nlp = spacy.load("en_core_web_sm")
nlp.max_length = 9000000 #or any large value, as long as you don't run out of RAM

def read_texts_from_folder(folder_path):
    """Reads all .txt files from the given folder and returns a dictionary with file names as keys and contents as values."""
    texts = {}
    for file_name in os.listdir(folder_path):
        if file_name.endswith(".txt"):  # Process only .txt files
            with open(os.path.join(folder_path, file_name), "r", encoding="utf-8") as file:
                texts[file_name] = file.read()
    return texts

def chunk_text(text, sentences_per_chunk=6):
    """Chunks a single text into six-sentence chunks."""
    # Process the text with spaCy
    doc = nlp(text)
    
    # Split into sentences
    sentences = [sent.text.strip() for sent in doc.sents]
    
    # Create chunks of sentences, with the last chunk possibly containing fewer than 6 sentences
    chunks = [
        " ".join(sentences[i:i + sentences_per_chunk]) 
        for i in range(0, len(sentences), sentences_per_chunk)
    ]
    
    # Return the chunks as a list
    return chunks

def process_folder_to_chunks(folder_path, sentences_per_chunk=6, output_folder=None):
    """Processes all text files in a folder, chunks them, and creates a DataFrame with 'Passage' and 'Tag' columns."""
    texts = read_texts_from_folder(folder_path)
    for file_name, text in texts.items():
        # Chunk the text
        chunks = chunk_text(text, sentences_per_chunk)
         # Create a DataFrame with 'Passage' and 'Tag' columns
        df = pd.DataFrame({"Passage": chunks, "Tag": ""})  # Empty cells for the 'Tag' column
        
        
        # Save the DataFrame to an Excel file
        if output_folder:
            os.makedirs(output_folder, exist_ok=True)
            output_file = os.path.join(output_folder, f"{file_name}_chunks.xlsx")
        else:
            output_file = f"{file_name}_chunks.xlsx"
        
        df.to_excel(output_file, index=False, engine='openpyxl')  # Save as Excel
        print(f"Processed and saved: {output_file}")


# Example usage
folder_path = "/Users/.../Domestic_Space_Project/Data_Preparation_Chadwyck/for_processing"  # Replace with your folder path
output_folder = "/Users/.../Domestic_Space_Project/Data_Preparation_Chadwyck/processed_chunks"  # Output folder for CSVs

# Process the folder and save results
process_folder_to_chunks(folder_path, sentences_per_chunk=6, output_folder=output_folder)
