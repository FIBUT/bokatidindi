import 'cypress-accessibility-checker';

describe('Basic templates should not regress in accessibility', () => {
  it('passes', () => {
    cy.visit('/')
    .getCompliance('landing')
    .assertCompliance()
    .then(result => {
      expect(result).to.lessThanOrEqual(0)
    });
    
    cy.visit('/baekur')
    .getCompliance('book-index')
    .assertCompliance()
    .then(result => { expect(result).to.lessThanOrEqual(0) });
    
    // Click the first book on the list and see if it complies
    cy.get('article:first-child a')
    .first()
    .invoke('attr', 'href')
    .then((href) => cy.visit(href as string))
    .then(() => {
      cy.getCompliance('book').assertCompliance();
    });
  })
});
