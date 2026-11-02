package br.com.fiap.zelo.service;

import br.com.fiap.zelo.dto.ResumoCuidados;
import br.com.fiap.zelo.model.*;
import br.com.fiap.zelo.repository.CuidadoRepository;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import jakarta.persistence.criteria.Predicate;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;

@Service
public class CuidadoConsultaService {
 private final CuidadoRepository repository;
 public CuidadoConsultaService(CuidadoRepository repository) { this.repository = repository; }
 public List<Cuidado> listar(Long petId, StatusCuidado status, LocalDate inicio, LocalDate fim) {
  return repository.findAll(filtro(petId, status, inicio, fim), Sort.by("dataPrevista").ascending().and(Sort.by("id")));
 }
 private Specification<Cuidado> filtro(Long petId, StatusCuidado status, LocalDate inicio, LocalDate fim) {
  if (inicio != null && fim != null && inicio.isAfter(fim))
   throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "dataInicio deve ser anterior ou igual a dataFim");
  return (root, query, cb) -> {
   List<Predicate> parts = new ArrayList<>();
   if (petId != null) parts.add(cb.equal(root.get("pet").get("id"), petId));
   if (status != null) parts.add(cb.equal(root.get("status"), status));
   if (inicio != null) parts.add(cb.greaterThanOrEqualTo(root.<LocalDate>get("dataPrevista"), inicio));
   if (fim != null) parts.add(cb.lessThanOrEqualTo(root.<LocalDate>get("dataPrevista"), fim));
   return cb.and(parts.toArray(new Predicate[0]));
  };
 }
 public ResumoCuidados resumir(Long petId, StatusCuidado status, LocalDate inicio, LocalDate fim) {
  var cuidados = listar(petId, status, inicio, fim);
  long pendentes=0, atrasados=0, concluidos=0, cancelados=0;
  LocalDate hoje = LocalDate.now(ZoneOffset.UTC);
  for (var cuidado : cuidados) {
   switch(cuidado.getStatus()) {
    case CONCLUIDO -> concluidos++;
    case CANCELADO -> cancelados++;
    case ATRASADO -> atrasados++;
    case PENDENTE -> { if(cuidado.getDataPrevista().isBefore(hoje)) atrasados++; else pendentes++; }
   }
  }
  return new ResumoCuidados(cuidados.size(),pendentes,atrasados,concluidos,cancelados);
 }
}
