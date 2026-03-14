package com.javatechie;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class DevopsIntegrationApplication {

    @GetMapping("/")
    public String message(){
        return """
        <html>
        <head>
            <title>DevOps CI/CD Project</title>
            <style>
                body{
                    font-family: Arial, sans-serif;
                    background: linear-gradient(135deg,#0f2027,#203a43,#2c5364);
                    color:white;
                    text-align:center;
                    padding-top:120px;
                }
                .card{
                    background:rgba(255,255,255,0.1);
                    padding:40px;
                    border-radius:15px;
                    width:500px;
                    margin:auto;
                    box-shadow:0 0 25px rgba(0,0,0,0.4);
                }
                h1{
                    color:#00ffd5;
                }
                p{
                    font-size:18px;
                }
                .tech{
                    margin-top:20px;
                    font-weight:bold;
                    color:#ffd369;
                }
            </style>
        </head>

        <body>

            <div class="card">
                <h1>🚀 DevOps CI/CD Pipeline Project</h1>
                <p>Application Successfully Deployed!</p>

                <p class="tech">
                Built with: Spring Boot | Docker | Jenkins | Kubernetes
                </p>

                <p>
                Continuous Integration & Continuous Deployment
                implemented by <b>Omswarup Nanda</b>
                </p>

                <p>⚙️ Powered by Automated DevOps Pipeline</p>
            </div>

        </body>
        </html>
        """;
    }

    public static void main(String[] args) {
        SpringApplication.run(DevopsIntegrationApplication.class, args);
    }
}
