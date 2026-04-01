import { NestFactory, Reflector } from '@nestjs/core';
import { ValidationPipe, ClassSerializerInterceptor } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import * as helmet from 'helmet';
import * as cookieParser from 'cookie-parser';
import { AppModule } from './app.module';
import { GlobalHttpExceptionFilter } from './common/filters/http-exception.filter';
import { LoggingInterceptor } from './common/interceptors/logging.interceptor';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // cookie-parser debe registrarse ANTES que cualquier guard o middleware que
  // lea req.cookies. Sin esto, JwtRefreshStrategy no puede leer refresh_token
  // de la cookie y el flujo cookie-based falla silenciosamente con 401.
  app.use((cookieParser as any).default());

  // Helmet agrega headers HTTP de seguridad (XSS, clickjacking, MIME sniffing, etc.)
  // contentSecurityPolicy: false — necesario para que Swagger UI cargue sus scripts.
  // Sin esto la UI carga la shell HTML pero los scripts quedan bloqueados por CSP.
  // En producción (Fase 9) configurar una CSP explícita que permita los assets de Swagger.
  app.use((helmet as any).default({ contentSecurityPolicy: false }));

  // Prefijo global /api para todas las rutas.
  // Swagger queda en /api/docs, endpoints en /api/animales, /api/auth/login, etc.
  app.setGlobalPrefix('api');

  // credentials: true permite que los browsers envíen cookies HTTP-only en
  // peticiones cross-origin (necesario para el flujo cookie-based del refresh token).
  // origin: true refleja el Origin del request → permite cualquier origen en dev.
  // En producción (Fase 9) cambiar a: origin: 'https://app.farmlink.com'
  app.enableCors({
    origin: true,
    credentials: true,
  });

  // GlobalHttpExceptionFilter — estandariza TODAS las respuestas de error.
  // { statusCode, message, path, timestamp }
  // Se registra ANTES de pipes e interceptors para capturar sus errores también.
  app.useGlobalFilters(new GlobalHttpExceptionFilter());

  // ValidationPipe valida automáticamente los DTOs con class-validator.
  // whitelist: true descarta campos no declarados en el DTO.
  // forbidNonWhitelisted: true lanza 400 si llegan campos extra.
  // transform: true convierte el body al tipo del DTO automáticamente.
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // LoggingInterceptor registrado primero → envuelve la cadena completa (mide tiempo total).
  // ClassSerializerInterceptor registrado segundo → aplica @Exclude()/@Expose()
  // de class-transformer en las respuestas (oculta password, refresh_token_hash).
  app.useGlobalInterceptors(
    new LoggingInterceptor(),
    new ClassSerializerInterceptor(app.get(Reflector)),
  );

  // Swagger / OpenAPI — disponible en GET /api/docs
  // addBearerAuth() habilita el botón "Authorize" con Bearer JWT en la UI.
  // El nombre 'access-token' debe coincidir con @ApiBearerAuth('access-token') en controllers.
  const config = new DocumentBuilder()
    .setTitle('FarmLink API')
    .setDescription(
      'API multitenant para gestión ganadera. ' +
        'Todas las rutas protegidas requieren Bearer token JWT. ' +
        'Obtener token en POST /auth/login.',
    )
    .setVersion('1.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'Authorization',
        description: 'Introduce tu access_token (sin prefijo Bearer)',
        in: 'header',
      },
      'access-token',
    )
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document, {
    swaggerOptions: {
      // Mantiene la autorización entre recargas de página en desarrollo
      persistAuthorization: true,
    },
  });

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
