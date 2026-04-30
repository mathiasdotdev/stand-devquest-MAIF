import type { DisasterType, DisasterResult } from "../../shared/models/Disaster";
import type { ActiveContract } from "../../shared/models/Contract";
import { DISASTERS_CONFIG } from "../../shared/config/disastersConfig";
import { CONTRACTS_CONFIG } from "../../shared/config/contractsConfig";
import { EconomyManager } from "./EconomyManager";

export class DisasterResolver {
  /**
   * Résout un sinistre en fonction des contrats actifs.
   * Retourne le résultat (coût effectif, couverture, franchise).
   */
  resolve(
    type: DisasterType,
    activeContracts: ActiveContract[],
    damageMultiplier: number
  ): DisasterResult {
    const def = DISASTERS_CONFIG[type];
    const baseDamage = Math.floor(def.baseDamage * damageMultiplier);

    // Cherche un contrat actif qui couvre ce sinistre
    const coveringContract = activeContracts.find((contract) =>
      def.coveringContracts.includes(contract.type)
    );

    if (!coveringContract) {
      return {
        type,
        baseDamage,
        actualCost: baseDamage,
        wasCovered: false,
        coveringContractType: null,
        franchiseAmount: 0,
      };
    }

    // Couvert : calcul de la franchise
    const contractDef = CONTRACTS_CONFIG.find((c) => c.type === coveringContract.type);
    const franchise = contractDef ? contractDef.levels[coveringContract.level].franchise : 0;
    const franchiseAmount = EconomyManager.franchiseCost(baseDamage, franchise);

    return {
      type,
      baseDamage,
      actualCost: franchiseAmount,
      wasCovered: true,
      coveringContractType: coveringContract.type,
      franchiseAmount,
    };
  }
}
