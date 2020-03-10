%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Authors: Rahul Chandan, Dario Paccagnan, Jason Marden
%   Copyright (c) 2020 Rahul Chandan, Dario Paccagnan, Jason Marden. 
%   All rights reserved. See LICENSE file in the project root for full license information.
%
%   Description:
%   Optimizes the price-of-anarchy (by designing additive tolls) 
%   of polynomial congestion games with latencies obtained as linear 
%   combination of basis {b_1(x),...,b_m(x)}, and n players
%
%   Inputs:
%       Name        Size        Description
%       `n`         1x1 int     Number of players.
%       `B`         mxn real    Resource cost functions, each row 
%                               corresponds to a basis in {b_1(x),...,b_m(x)}
%
%       `platform`  struct      Choice of solver and options
%
%                             - platform.solver  
%                               1 (uses matlab linprog solver) or
%                               0 (uses YALMIP interface) 
%                               
%                             - platform.matlabOptions sets solver options
%                               for linprog (only if platform.solver = 1) 
%                               Example: platform.matlabOptions = 
%                                   optimoptions('linprog','Algorithm', ...
%                                   'dual-simplex');
%
%                             - platform.yalmipOptions sets solver options
%                               for YALMIP (only if platform.solver = 0) 
%                               Example: platform.yalmipOptions =
%                                   sdpsettings('solver', 'gurobi')
%   Outputs:
%       Name        Size        Description
%       `OptPoA`    1x1 real    Optimal price-of-anarchy
%       `Optf       mxn real    Optf can be used to costruct optimal
%                               tolls, see ArXiv:1911.09806v2. Each row
%                               corresponds to a different basis
%      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [OptPoA, Optf] = optimizeCostMinPoA(n, B, platform)

    % Solver options
    if platform.solver == 1 
        % to use Matlab built in LinProg with options
        platform.name = 'matlab-built-in'; 
        platform.options = platform.matlabOptions;
        fprintf('\n')
        warning(sprintf('\nYou are using the matlab linprog solver.\nWe recommend YALMIP + gurobi for accuracy.\nTo use YALMIP, set platform.solver=0\n'));


    elseif platform.solver == 0
        % to use YALMIP with options
        platform.name = 'YALMIP'; 
        platform.options = platform.yalmipOptions;

    else, error('Wrong choice of solver.');

    end
    
    % Initialize
    m = size(B,1);
    OptPoA = 0;
    Optf = zeros(m,n); 
    
    % For each basis compute the optimal tolling mechanism
    for current_basis = 1 : m
        b = B(current_basis, :);                           
        c = (1:n).*b;
    
        % Compute optimal toll for current basis 
        [x, ~, exitflag, output] = optimalLP(n, [0 c 0]', 1, platform);
        
        if exitflag ~= 1
            error(output.message)
        end
        
        
        Optf(current_basis,:) = x(1:n); % Store the optimal mechanism
        currentOptPoA = 1/x(n+1);
        

        % Optimal poa is the largest over all bases
        OptPoA = max( currentOptPoA, max(OptPoA) );
    end
   
end
