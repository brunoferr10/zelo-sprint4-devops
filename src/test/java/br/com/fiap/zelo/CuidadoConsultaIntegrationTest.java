package br.com.fiap.zelo;
import br.com.fiap.zelo.model.*;
import br.com.fiap.zelo.repository.*;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDate;
import java.time.ZoneOffset;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
@SpringBootTest @AutoConfigureMockMvc @ActiveProfiles("test") @Transactional
class CuidadoConsultaIntegrationTest {
 @Autowired MockMvc mvc;
 @Autowired PetRepository pets;
 @Autowired CuidadoRepository cuidados;
 private Pet pet(String nome) {
  Pet p=new Pet();p.setNome(nome);p.setEspecie("Cao");p.setNomeTutor("Tutor");p.setDataNascimento(LocalDate.of(2020,1,1));return pets.save(p);
 }
 private void cuidado(Pet p,StatusCuidado status,LocalDate data) {
  Cuidado c=new Cuidado();c.setPet(p);c.setStatus(status);c.setDataPrevista(data);c.setTipo("CONSULTA");c.setDescricao("Retorno");cuidados.saveAndFlush(c);
 }
 @Test void combinaFiltrosComLimitesInclusivosEOrdena() throws Exception {
  Pet p=pet("Teste filtro"), outro=pet("Outro"); LocalDate d=LocalDate.of(2030,1,10);
  cuidado(p,StatusCuidado.PENDENTE,d.plusDays(1));cuidado(p,StatusCuidado.PENDENTE,d);
  cuidado(p,StatusCuidado.PENDENTE,d.minusDays(1));cuidado(p,StatusCuidado.CONCLUIDO,d);
  cuidado(outro,StatusCuidado.PENDENTE,d);
  mvc.perform(get("/api/cuidados").param("petId",p.getId().toString()).param("status","PENDENTE")
   .param("dataInicio",d.toString()).param("dataFim",d.plusDays(1).toString()))
   .andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(2))
   .andExpect(jsonPath("$[0].dataPrevista").value(d.toString())).andExpect(jsonPath("$[1].dataPrevista").value(d.plusDays(1).toString()));
 }
 @Test void resumoClassificaAtrasoSemContarDuasVezes() throws Exception {
  Pet p=pet("Resumo");LocalDate hoje=LocalDate.now(ZoneOffset.UTC);
  cuidado(p,StatusCuidado.PENDENTE,hoje.minusDays(1));cuidado(p,StatusCuidado.PENDENTE,hoje);
  cuidado(p,StatusCuidado.ATRASADO,hoje);cuidado(p,StatusCuidado.CONCLUIDO,hoje.minusDays(1));cuidado(p,StatusCuidado.CANCELADO,hoje);
  mvc.perform(get("/api/cuidados/resumo").param("petId",p.getId().toString()))
   .andExpect(status().isOk()).andExpect(jsonPath("$.total").value(5)).andExpect(jsonPath("$.pendentes").value(1))
   .andExpect(jsonPath("$.atrasados").value(2)).andExpect(jsonPath("$.concluidos").value(1)).andExpect(jsonPath("$.cancelados").value(1));
 }
 @Test void resumoRespeitaFiltrosEDistingueListaVazia() throws Exception {
  Pet p=pet("Filtrado");LocalDate d=LocalDate.of(2030,1,10);
  cuidado(p,StatusCuidado.CONCLUIDO,d);cuidado(p,StatusCuidado.CANCELADO,d);
  mvc.perform(get("/api/cuidados/resumo").param("petId",p.getId().toString()).param("status","CONCLUIDO").param("dataInicio",d.toString()).param("dataFim",d.toString()))
   .andExpect(status().isOk()).andExpect(jsonPath("$.total").value(1)).andExpect(jsonPath("$.concluidos").value(1));
  mvc.perform(get("/api/cuidados/resumo").param("petId",p.getId().toString()).param("dataInicio","2031-01-01"))
   .andExpect(status().isOk()).andExpect(jsonPath("$.total").value(0));
 }
 @Test void rejeitaPeriodoInvertidoNasDuasRotas() throws Exception {
  for(String path : new String[]{"/api/cuidados","/api/cuidados/resumo"})
   mvc.perform(get(path).param("dataInicio","2030-02-01").param("dataFim","2030-01-01")).andExpect(status().isBadRequest());
 }
 @Test void rejeitaStatusOuDataInvalidos() throws Exception {
  mvc.perform(get("/api/cuidados").param("status","INVALIDO")).andExpect(status().isBadRequest());
  mvc.perform(get("/api/cuidados/resumo").param("dataInicio","nao-e-data")).andExpect(status().isBadRequest());
 }
}
