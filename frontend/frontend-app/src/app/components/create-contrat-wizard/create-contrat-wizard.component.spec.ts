import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CreateContratWizardComponent } from './create-contrat-wizard.component';

describe('CreateContratWizardComponent', () => {
  let component: CreateContratWizardComponent;
  let fixture: ComponentFixture<CreateContratWizardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CreateContratWizardComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(CreateContratWizardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
