class RuleResolver {
  final Map<String, dynamic>? armyData;

  RuleResolver(this.armyData);

  Map<String, dynamic>? findRuleDetail(Map<String, dynamic> rule) {
    final String name = (rule['name'] ?? '').toString().toLowerCase().trim();
    final String id = (rule['id'] ?? '').toString().trim();

    final rootRules = armyData?['specialRules'] as List?;
    if (rootRules != null) {
      if (id.isNotEmpty) {
        for (final r in rootRules) {
          if (r is Map && r['id']?.toString().trim() == id) {
            return Map<String, dynamic>.from(r);
          }
        }
      }

      if (name.isNotEmpty) {
        for (final r in rootRules) {
          if (r is Map && r['name']?.toString().toLowerCase().trim() == name) {
            return Map<String, dynamic>.from(r);
          }
        }
      }
    }

    // Fallback dictionary for core rules not defined/described in the JSON
    const coreRulesFallback = {
      'ambush': 'May be set aside before deployment. At the start of any round after the first, may be deployed anywhere over 9” away from enemy units. Players alternate in placing Ambush units, starting with the player that activates next. Units that deploy via Ambush can’t seize or contest objectives on the round they deploy.',
      'ap': 'Targets get -X to Defense rolls when blocking hits from this weapon.',
      'artillery': 'May only use Hold actions. When this model shoots at enemies over 9" away, it gets +1 to hit rolls. When enemy units shoot at this model from over 9" away, they get -2 to hit rolls.',
      'bane': 'Ignores Regeneration, and when attacking the target must re-roll unmodified Defense results of 6.',
      'blast': 'Ignores cover, and after resolving other special rules, each hit is multiplied by X, where X is up to as many hits as models in the target unit.',
      'caster': 'Gets X spell tokens at the start of each round, but can’t hold more than 6 tokens at once. At any point before attacking, spend as many tokens as the spell’s value to try casting one or more spells (only one try per spell). Roll one die, on 4+ resolve the effect on a target in line of sight. Models within 18” in line of sight of the caster’s unit may spend any number of spell tokens at the same time before rolling, to give the caster +1/-1 to the roll per token.',
      'counter': 'Strikes first with this weapon when charged, and the charging unit gets -1 total Impact rolls per model with Counter.',
      'deadly': 'Assign each wound to one model, and multiply it by X. Hits from Deadly must be resolved first, and these wounds don’t carry over to other models if the original target is killed.',
      'fast': 'Moves +2” when using Advance and +4” when using Rush/Charge.',
      'fear': 'This model counts as having dealt +X wounds when checking who won melee.',
      'fearless': 'When a unit where all models have this rule fails a morale test, roll one die. On a 4+ it counts as passed instead.',
      'flying': 'May move through units and terrain, and ignores terrain effects whilst moving.',
      'furious': 'When charging, unmodified results of 6 to hit in melee deal 1 extra hit (only the original hit counts as a 6 for special rules).',
      'hero': 'Heroes with up to Tough(6) may deploy as part of one multi-model unit without another Hero. The hero may take morale tests on behalf of the unit, but must use the unit’s Defense until all other models have been killed.',
      'immobile': 'May only use Hold actions.',
      'impact': 'Roll X dice when attacking after charging, unless fatigued. For each 2+ the target takes one hit.',
      'indirect': 'Gets -1 to hit rolls when shooting after moving. May target enemies that are not in line of sight as if in line of sight, and ignores cover from sight obstructions.',
      'limited': 'May only be used once per game.',
      'regeneration': 'When a unit where all models have this rule takes wounds, roll one die for each. On a 5+ it is ignored.',
      'relentless': 'When this model shoots at enemies over 9" away, unmodified results of 6 to hit deal 1 extra hit (only the original hit counts as a 6 for special rules).',
      'reliable': 'Attacks at Quality 2+.',
      'rending': 'Ignores Regeneration, and on unmodified results of 6 to hit, those hits get AP(+4).',
      'scout': 'May be set aside before deployment. After all other units are deployed, may be deployed anywhere fully within 12” of their deployment zone. Players alternate in placing Scout units, starting with the player that activates next.',
      'slow': 'Moves -2” when using Advance, and -4” when using Rush/Charge.',
      'stealth': 'When units where all models have this rule are shot from over 9" away, enemy units get -1 to hit rolls.',
      'strider': 'May ignore the effects of difficult terrain when moving.',
      'surge': 'On unmodified results of 6 to hit, this weapon deals 1 extra hit (only the original hit counts as a 6 for special rules).',
      'takedown': 'This model may pick any model in the target unit as its individual target, which is resolved as if it was a unit of [1]. Takedown attacks must be resolved before other weapons.',
      'thrust': 'When charging, gets +1 to hit rolls and AP(+1) in melee.',
      'tough': 'This model must take X wounds before being killed. If a model with tough joins a unit without it, then it is removed last when the unit takes wounds. You must continue to put wounds on the tough model with most wounds in the unit until it is killed, before starting to put them on the next tough model (heroes must be assigned wounds last, even if already wounded).',
      'unstoppable': 'Ignores Regeneration, and ignores all negative modifiers to this weapon.',
      'sergeant': 'When this model attacks, unmodified results of 6 to hit deal 1 extra hit (only the original hit counts as a 6 for special rules).',
      'musician': 'This model and its unit move +1” when using move actions.',
      'banner': 'This model and its unit get +1 to morale test rolls.',
    };

    if (coreRulesFallback.containsKey(name)) {
      return {
        'name': rule['name'] ?? name,
        'description': coreRulesFallback[name],
      };
    }

    return null;
  }
}
