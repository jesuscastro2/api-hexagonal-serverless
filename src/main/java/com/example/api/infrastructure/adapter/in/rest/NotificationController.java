
package com.example.api.infrastructure.adapter.in.rest;

import com.example.api.application.service.NotificationService;
import com.example.api.infrastructure.adapter.in.rest.dto.NotificationRequest;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(
            NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @PostMapping("/send")
    public ResponseEntity<Map<String, String>> enviar(
            @Valid @RequestBody NotificationRequest request) {

        String messageId = notificationService.enviar(
                request.email(),
                request.asunto(),
                request.mensaje()
        );

        return ResponseEntity.accepted().body(
                Map.of(
                        "status", "accepted",
                        "messageId", messageId,
                        "message", "Notificación publicada en SNS"
                )
        );
    }
}
