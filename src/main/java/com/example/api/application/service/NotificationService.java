
package com.example.api.application.service;

import com.example.api.domain.ports.out.NotificationPublisherPort;
import org.springframework.stereotype.Service;

@Service
public class NotificationService {

    private final NotificationPublisherPort notificationPublisher;

    public NotificationService(
            NotificationPublisherPort notificationPublisher) {
        this.notificationPublisher = notificationPublisher;
    }

    public String enviar(
            String email,
            String asunto,
            String mensaje) {

        return notificationPublisher.publicarNotificacion(
                email,
                asunto,
                mensaje
        );
    }
}
