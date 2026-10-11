
package com.example.api.domain.ports.out;

public interface NotificationPublisherPort {

    String publicarNotificacion(
            String email,
            String asunto,
            String mensaje
    );
}
