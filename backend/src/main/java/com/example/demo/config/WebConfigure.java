package com.example.demo.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfigure implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // "/uploads/**" → accessible depuis le navigateur
        // "file:uploads/" → chemin physique sur ton serveur
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:uploads/");
    }
}