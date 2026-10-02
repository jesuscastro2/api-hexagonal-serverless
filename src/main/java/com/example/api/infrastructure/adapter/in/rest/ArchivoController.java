package com.example.api.infrastructure.adapter.in.rest;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@RestController
@RequestMapping("/api/archivos")
public class ArchivoController {

    @PostMapping(
            value = "/upload",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ResponseEntity<String> subirArchivo(
            @RequestParam("file") MultipartFile file) {

        if (file.isEmpty()) {
            return ResponseEntity.badRequest()
                    .body("El archivo está vacío");
        }

        try {
            Path directorio = Paths.get("uploads");

            Files.createDirectories(directorio);

            String nombreOriginal = Paths
                    .get(file.getOriginalFilename())
                    .getFileName()
                    .toString();

            String nombreArchivo =
                    UUID.randomUUID() + "_" + nombreOriginal;

            Path destino = directorio.resolve(nombreArchivo);

            Files.copy(
                    file.getInputStream(),
                    destino,
                    StandardCopyOption.REPLACE_EXISTING
            );

            return ResponseEntity.ok(
                    "Archivo subido correctamente: " + nombreArchivo
            );

        } catch (IOException e) {

            return ResponseEntity.internalServerError()
                    .body("Error al guardar el archivo: " + e.getMessage());
        }
    }
}