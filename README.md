# 🇮🇷 IRAN CV Analyzer

Upload your resume → Get AI-powered career insights

---

## 🧠 Overview

IRAN CV Analyzer is a smart AI-powered Shiny application that analyzes resumes locally using **Ollama + Llama 3.2** and provides:

- Job role suggestions  
- Missing skills detection  
- Personalized career roadmap  

---

## 🛠 Built With

- R  
- Shiny  
- Ollama (Local LLM runtime)  
- Llama 3.2  

---

## ✨ Features

- 📄 Resume (PDF) upload  
- 🧠 AI-powered CV analysis  
- 🎯 Job recommendation system  
- 📉 Skill gap detection  
- 🗺 Career roadmap generation  
- 🔒 Fully local AI (no cloud API needed)

---

## 📊 Preview

![Dashboard](dashboard.png)

---

## 🔌 Local AI Setup (Ollama)

This project runs fully locally using **Ollama**.

---

### 1. Install Ollama

Download and install from:

https://ollama.com

---

### 2. Pull the model

Open CMD (Run as Administrator) and run:

```bash
ollama pull llama3.2
3. Start Ollama server

Run the local server:

ollama serve

Ollama will run by default on:

http://localhost:11434

▶️ Run the App (R)

Install required packages:

install.packages(c("shiny", "httr", "jsonlite", "stringr"))

Run the application:

source("IRAN_CV.R")
⚠️ Important Flow

Make sure you follow this order:

Start Ollama (ollama serve)
Ensure model is downloaded (llama3.2)
Run the R Shiny app
Upload your CV in the interface
🚀 Result
After upload, the system generates:
Suggested job roles
Missing skill analysis
Career development roadmap
