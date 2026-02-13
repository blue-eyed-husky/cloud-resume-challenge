## Cloud Resume Challenge 

This is a serverless, cloud-native resume site built on AWS with Infrastructure as Code and CI/CD
This project demonstrates front-end hosting, CDN, API, serverless compute, database, automation, and observability.


**Live Site**
**API endpoint**
**Architecture Diagram**

## Overview
This project implements a secure, static website architecture on AWS using Terraform. Th goal is to demonstrate infrastructure as Code, secure origin design (originally public S3 bucket site endpoint), CDN configuration, DNS management, and cloud troubleshooting practices. 


## What this Project Demonstrates 
IAC (Terraform) 
- Declarative AWS resource provisioning
- State management 
- Resource dependecy handling
- Safe refactoring







## Lessons Learned
- Website endpoint and REST endpoint behave differently
- CloudFront distribution updates and propagation takes time (1 hour in my case)
- DNS changes require propagation patience