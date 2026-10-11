
package com.example.api.infrastructure.adapter.out.messaging;

import com.example.api.domain.ports.out.NotificationPublisherPort;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.services.sns.SnsClient;
import software.amazon.awssdk.services.sns.model.PublishRequest;
import software.amazon.awssdk.services.sns.model.PublishResponse;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.Map;

@Component
public class SnsNotificationPublisherAdapter
        implements NotificationPublisherPort {

    private final SnsClient snsClient;
    private final ObjectMapper objectMapper;
    private final String topicArn;

    public SnsNotificationPublisherAdapter(
            SnsClient snsClient,
            ObjectMapper objectMapper,
            @Value("${aws.sns.topic-arn}") String topicArn) {
        this.snsClient = snsClient;
        this.objectMapper = objectMapper;
        this.topicArn = topicArn;
    }

    @Override
    public String publicarNotificacion(
            String email,
            String asunto,
            String mensaje) {

        try {
            String payload = objectMapper.writeValueAsString(
                    Map.of(
                            "email", email,
                            "subject", asunto,
                            "message", mensaje
                    )
            );

            PublishResponse response = snsClient.publish(
                    PublishRequest.builder()
                            .topicArn(topicArn)
                            .message(payload)
                            .build()
            );

            return response.messageId();

        } catch (JsonProcessingException e) {
            throw new IllegalStateException(
                    "No se pudo construir el mensaje de notificación", e);
        }
    }
}
