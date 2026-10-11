
package com.example.api.infrastructure.adapter.in.rest.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record NotificationRequest(

        @NotBlank
        @Email
        String email,

        @NotBlank
        @Size(max = 150)
        String asunto,

        @NotBlank
        @Size(max = 4000)
        String mensaje

) {}
