# Cloud-native Kubernetes application to efficiently and securely stream and collect real-time data

This repository contains the code for my [master's degree thesis project](https://webthesis.biblio.polito.it/secure/26694/1/tesi.pdf), focusing on the development of a cloud-native application. The project utilizes a microservice application hosted on Google Kubernetes Engine (GKE) to securely stream and store data collected from numerous sensors distributed across various geographical locations.

## Layout

    .
    ├── Authentication          # Spring microservice dedicated to authentication management
    ├── HistoricalData          # Spring microservice offering APIs for retrieving historical data from the database
    ├── k8s                     # Kubernetes manifest files
    ├── KafkaClients            # Apache Kafka producer and consumer modules for testing purposes
    ├── myKafkaConnect          # Docker image for Kafka Connect
    ├── scripts                 # Scripts for easy application setup and testing
    ├── package.json
    └── README.md

